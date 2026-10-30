pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property var fallbackColors: ({
        surface_container: "#211f26",
        on_surface: "#e6e1e5",
        on_surface_variant: "#cac4d0",
        primary: "#d0bcff",
        primary_container: "#4f378b",
        on_primary_container: "#eaddff"
    })
    property var colors: fallbackColors

    readonly property color surfaceContainer: colors.surface_container
    readonly property color onSurface: colors.on_surface
    readonly property color onSurfaceVariant: colors.on_surface_variant
    readonly property color primary: colors.primary
    readonly property color primaryContainer: colors.primary_container
    // QML treats onPrimaryContainer as a handler beside primaryContainer.
    readonly property color primaryContainerText: colors.on_primary_container

    FileView {
        path: Quickshell.shellPath("colors.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const next = JSON.parse(text());
                for (const name of Object.keys(root.fallbackColors)) {
                    if (typeof next[name] !== "string" || !/^#[0-9a-f]{6}$/i.test(next[name]))
                        throw new Error("Invalid color: " + name);
                }
                root.colors = next;
            } catch (error) {
                console.warn("Keeping previous Quickshell palette:", error.message);
            }
        }
    }
}
