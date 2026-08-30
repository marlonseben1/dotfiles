export ZSH="$HOME/.oh-my-zsh"

# THEME
ZSH_THEME="robbyrussell"

zstyle ':omz:update' frequency 7

plugins=(git)

source $ZSH/oh-my-zsh.sh

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ---- DECOMPOSE CHAVE ACESSO ----#

decompose_chave() {
    local chave="$1"

    if [[ ! $chave =~ ^[0-9]{44}$ ]]; then
        echo "Erro: A chave de acesso deve ter exatamente 44 dígitos numéricos."
        return 1
    fi

    local cUF="${chave:0:2}"
    local AAMM="${chave:2:4}"
    local CNPJ="${chave:6:14}"
    local mod="${chave:20:2}"
    local serie="$((10#${chave:22:3}))"
    local numDF="$((10#${chave:25:9}))"
    local tpEmis="${chave:34:1}"
    local cNF="${chave:35:8}"
    local cDV="${chave:43:1}"

    local doc_name="Desconhecido"
    case $mod in
        55) doc_name="NF-e" ;;
        57) doc_name="CT-e" ;;
        58) doc_name="MDF-e" ;;
        59) doc_name="CF-e" ;;
        63) doc_name="BP-e" ;;
        64) doc_name="GTV-e" ;;
        65) doc_name="NFC-e" ;;
        66) doc_name="NF3-e" ;;
        67) doc_name="CT-e OS" ;;
    esac

    echo "------------------------------"
    echo " Chave de Acesso - $doc_name "
    echo "------------------------------"
    echo "Código da UF:     $cUF"
    echo "Ano e Mês:        $AAMM"
    echo "CNPJ do Emitente: $CNPJ"
    echo "Modelo:           $mod - $doc_name"
    printf "Série:            %-3s\n" "$serie"
    printf "Número:           %-9s\n" "$numDF"
    echo "Forma de emissão: $tpEmis"
    echo "Código Numérico:  $cNF"
    echo "Dígito Verif.:    $cDV"
    echo "------------------------------"
}

# ---- GET CHAVE ACESSO ----#

get_chave() {
    local file="$1"
    if [[ -z "$file" || ! -f "$file" ]]; then
        echo "Uso: get_chave <arquivo.xml>"
        return 1
    fi
    local chave
    chave=$(grep -oP '<inf(?:NFe|CTe|MDFe)\b[^>]*Id="[A-Za-z]+\K[0-9]{44}' "$file")
    if [[ -z "$chave" ]]; then
        echo "Chave de acesso não encontrada."
        return 1
    fi
    local mod="${chave:20:2}"
    local doc_name
    case $mod in
        55) doc_name="NF-e" ;;
        57) doc_name="CT-e" ;;
        58) doc_name="MDF-e" ;;
        *)  doc_name="Desconhecido" ;;
    esac
    echo "$doc_name: $chave"
}

# ---- SYNC GITLAB ACTIVITY ----#

sync() {
    local ENV_FILE="$HOME/.config/fedora-setup.env"
    [[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

    if [[ -z "$SYNC_EMAIL_PERSONAL" || -z "$SYNC_EMAIL_WORK" || ${#SYNC_SOURCE_REPOS[@]} -eq 0 || -z "$SYNC_LOG_REPO" ]]; then
        echo "sync: defina SYNC_EMAIL_PERSONAL, SYNC_EMAIL_WORK, SYNC_SOURCE_REPOS e SYNC_LOG_REPO em $ENV_FILE"
        echo "(veja config/fedora-setup.env.example no dotfiles)"
        return 1
    fi

    local DATE="${1:-$(date '+%Y-%m-%d')}"
    local SINCE="${DATE}T07:00:00"
    local UNTIL="${DATE}T23:59:59"

    local NEW_DATES=""
    local repo
    for repo in "${SYNC_SOURCE_REPOS[@]}"; do
        cd "$repo"
        git fetch --all -q
        NEW_DATES+=$'\n'"$(git log --all --format="%aI" \
          --after="$SINCE" --before="$UNTIL" \
          --author="$SYNC_EMAIL_PERSONAL" \
          --author="$SYNC_EMAIL_WORK")"
    done
    NEW_DATES=$(echo "$NEW_DATES" | sed '/^$/d' | sort -u)

    cd "$SYNC_LOG_REPO"
    local EXISTING=$(git log --format="%aI" | sort -u)

    local TO_CREATE=$(comm -23 <(echo "$NEW_DATES") <(echo "$EXISTING"))

    if [[ -z "$TO_CREATE" ]]; then
        echo "Nenhum commit novo para $DATE."
        return 0
    fi

    echo "$TO_CREATE" | while read d; do
        GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" \
            git commit --allow-empty -m "feat: digital logistics contribution" --no-gpg-sign
    done

    git push
    echo "Done: $(echo "$TO_CREATE" | wc -l) commits adicionados."
}

# ---- ALIASES ----#

#---------------START-------------#|
alias c="claude"                  #|
alias gpl='git pull'              #|
alias gc='git checkout'           #|
alias gs='git status'             #|
alias gcs='git checkout staging'  #|
alias gcst='git checkout stable'  #|
alias gcb='git checkout -b'       #|
alias gcm='git commit -m'         #|
alias gaa='git add .'             #|
alias gml='git merge -'           #|
alias gstm='git stash -u -m'      #|
alias gsp='git stash -pop'        #|
alias gsl='git stash list'        #|
alias pi='pnpm install'           #|
alias ptb='pnpm tsc --build'      #|
alias pdev='pnpm run dev'         #|
alias ba='bun add'                #|
alias bi='bun install'            #|
alias bdev='bun run dev'          #|
alias killport≃'fuser -k'         #|
#---------------END---------------#|

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
