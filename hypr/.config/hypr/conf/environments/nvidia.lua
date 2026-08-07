local environment = {
    GBM_BACKEND = "nvidia-drm", LIBVA_DRIVER_NAME = "nvidia", SDL_VIDEODRIVER = "wayland",
    WLR_DRM_NO_ATOMIC = "1", __GLX_VENDOR_LIBRARY_NAME = "nvidia", __NV_PRIME_RENDER_OFFLOAD = "1",
    __VK_LAYER_NV_optimus = "NVIDIA_only", WLR_NO_HARDWARE_CURSORS = "1",
    WLR_RENDERER_ALLOW_SOFTWARE = "1", MOZ_DISABLE_RDD_SANDBOX = "1", EGL_PLATFORM = "wayland",
    WLR_RENDERER = "vulkan", WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0",
    VDPAU_DRIVER = "nvidia", __GLX_SYNC_TO_VBLANK = "1", __GL_MaxFramesAllowed = "1",
}
for name, value in pairs(environment) do hl.env(name, value) end
hl.config({ cursor = { no_hardware_cursors = true } })
