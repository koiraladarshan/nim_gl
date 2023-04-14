#define KSAGL_IMPLEMENTATION_OPENGL

/* INITIALIZING NUKLEAR STUFFS */
#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT
#define NK_IMPLEMENTATION
#define NK_GLFW_GL3_IMPLEMENTATION
#define NK_KEYSTATE_BASED_INPUT
#include "ksa.h"
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include "nuklear_glfw.h"

#define WINDOW_WIDTH 1200
#define WINDOW_HEIGHT 800
#define MAX_VERTEX_BUFFER 512 * 1024
#define MAX_ELEMENT_BUFFER 128 * 1024
#define INCLUDE_OVERVIEW

struct nk_glfw maini_glfw = {0};
int window_width;
int window_height;
struct nk_context *main_ctx;
struct nk_colorf bg;
struct nk_font *font;

/* NUKLEAR WRAPPER */
void init_nk(GLFWwindow *window)
{
    main_ctx = nk_glfw3_init(&maini_glfw, window, NK_GLFW3_INSTALL_CALLBACKS);
    struct nk_font_atlas *atlas;
    nk_glfw3_font_stash_begin(&maini_glfw, &atlas);
    font = nk_font_atlas_add_from_file(atlas, "res/sanskrit.ttf", 20, 0);
    nk_glfw3_font_stash_end(&maini_glfw);
    nk_style_set_font(main_ctx, &font->handle);
}

void draw_nk()
{
    nk_glfw3_new_frame(&maini_glfw);
    if (nk_begin(main_ctx, "Debug", nk_rect(0, 0, 100, 100),
                 NK_WINDOW_BORDER | NK_WINDOW_TITLE))
    {
        nk_style_set_font(main_ctx, &font->handle);
        nk_layout_row_static(main_ctx, 20, 100 * 0.2 * 0.9, 1);
        nk_label(main_ctx, "Hello Bruh", NK_TEXT_ALIGN_CENTERED);
    }
    nk_end(main_ctx);
    nk_glfw3_render(&maini_glfw, NK_ANTI_ALIASING_ON, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER);
}

void destroy_nk()
{
    nk_glfw3_shutdown(&maini_glfw);
}

/* INITIALIZING GLEWS */
int init_glew()
{
    if (glewInit() == GLEW_OK)
        return 1;
    else
        return 0;
}

/* INITIALIZING GLFW STUFFS*/
void do_glfw_init()
{
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    glfwWindowHint(GLFW_SAMPLES, 4);
}

/* INITIALIZING OPENGL STUFFS*/
void GLAPIENTRY debugCall(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *message, const void *userParam)
{
    printf("OpenGl Error: \n");
    printf("%s, %d)\n", __FILE__, __LINE__);
    fprintf(stderr, "GL CALLBACK: %s type = 0x%x, severity = 0x%x, message = %s\n",
            (type == GL_DEBUG_TYPE_ERROR ? "** GL ERROR **" : ""),
            type, severity, message);
    exit(-1);
}

void debug_callback_setup()
{
    glDebugMessageCallback(debugCall, NULL);
}

/* OPENGL WRAPPERS */
void draw_arrays(unsigned int first, unsigned int count)
{
    glDrawArrays(GL_TRIANGLES, first, count);
}

void draw_elements(int count, void *data)
{
    // for(int i = 0; i < 6; i++)
    // {
    //     printf("%d\n", ((unsigned int*)(data))[i]);
    // }
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, data);
}

void clear_color(float r, float g, float b, float a)
{
    glClearColor(r, g, b, a);
}

void clear()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

unsigned int compile_shaders(const char *vshader_source, const char *fshader_source)
{
    printf("%s\n", vshader_source);
    printf("%s\n", fshader_source);
    unsigned int vshader, fshader, program;
    vshader = glCreateShader(GL_VERTEX_SHADER);
    fshader = glCreateShader(GL_FRAGMENT_SHADER);
    program = glCreateProgram();
    glShaderSource(vshader, 1, &vshader_source, NULL);
    glShaderSource(fshader, 1, &fshader_source, NULL);
    glCompileShader(vshader);
    glCompileShader(fshader);

    glAttachShader(program, vshader);
    glAttachShader(program, fshader);
    glLinkProgram(program);
    glDeleteShader(vshader);
    glDeleteShader(fshader);
    return program;
}

void bind_shader(unsigned int program)
{
    glUseProgram(program);
}

void setup_gl_viewport(int x, int y, int width, int height)
{
    glViewport(x, y, width, height);
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_ALWAYS);
}

void resize_gl_viewport(GLFWwindow *window)
{
    int width, height;
    glfwGetWindowSize(window, &width, &height);
    glViewport(0, 0, width, height);
}

void ksa_uniform_mat4(unsigned int program, char *name, float *value)
{
    glUniformMatrix4fv(glGetUniformLocation(program, name), 1, GL_FALSE, value);
}
