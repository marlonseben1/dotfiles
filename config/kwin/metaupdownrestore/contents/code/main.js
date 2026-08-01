var pendingRestore = null;

function minimizeFn() {
    var w = workspace.activeWindow;
    if (!w) return;
    w.minimized = true;
    pendingRestore = w;
}

function restoreFn() {
    try {
        if (pendingRestore && workspace.windowList().indexOf(pendingRestore) !== -1 && pendingRestore.minimized) {
            pendingRestore.minimized = false;
            workspace.activeWindow = pendingRestore;
            pendingRestore = null;
            return;
        }
    } catch (e) {
        pendingRestore = null;
    }
    var w = workspace.activeWindow;
    if (!w) return;
    try {
        if (w.maximizedVertically && w.maximizedHorizontally) {
            w.setMaximize(false, false);
            return;
        }
    } catch (e) {}
    w.setMaximize(true, true);
}

registerShortcut("MinimizeAndRemember", "Minimizar e lembrar (Meta+Down)", "Meta+Down", minimizeFn);
registerShortcut("RestoreOrMaximize", "Restaurar minimizada ou maximizar (Meta+Up)", "Meta+Up", restoreFn);
