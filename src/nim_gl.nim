import nim_glpkg/ksa as k
import nim_glpkg/glfw as g
import application/application as app
import nim_glpkg/glm as m

when isMainModule:
    ~@ g.init()
    do_glfw_init()
    let window: g.GLFWwindow = g.create_window()
    g.make_context_current(window)
    ~@ k.init_glew()
    debug_callback_setup()
    app.init()
    k.setup_gl_viewport()
    let mat4 : mat4 = ortho(0, 100, 0, 100, 0, 100)

    while !g.window_should_close(window):
        k.clear_color(1, 0, 1, 1)
        k.clear()
        app.draw()


        discard g.swap_buffers(window)
        k.resize_gl_viewport(window)
        g.poll_events()
    g.terminate()
