#define KSAGL_IMPLEMENTATION_OPENGL
#include "ksa.h"
#include <GL/glew.h>
#include <GLFW/glfw3.h>

void draw_arrays(unsigned int first, unsigned int count)
{
    glDrawArrays(GL_TRIANGLES,  first, count);
}

void draw_elements(int count, void* data)
{
    // for(int i = 0; i < 6; i++)
    // {
    //     printf("%d\n", ((unsigned int*)(data))[i]);
    // }
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, data);
}

int init_glew() 
{ 
    if(glewInit() == GLEW_OK)
        return 1;
    else
        return 0;
}

void clear_color(float r, float g, float b, float a)
{
    glClearColor(r, g, b, a);
}

void clear()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


void GLAPIENTRY debugCall(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *message, const void *userParam)
{
    printf("OpenGl Error: \n");
    printf("%s, %d)\n", __FILE__, __LINE__);
    fprintf( stderr, "GL CALLBACK: %s type = 0x%x, severity = 0x%x, message = %s\n",
           ( type == GL_DEBUG_TYPE_ERROR ? "** GL ERROR **" : "" ),
            type, severity, message );
//    exit(-1);
}

void do_glfw_init()
{
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    glfwWindowHint(GLFW_SAMPLES, 4);
}

void debug_callback_setup()
{
    glDebugMessageCallback(debugCall, NULL);
}

unsigned int compile_shaders(const char* vshader_source, const char* fshader_source)
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
    glEnable(GL_DEPTH_TEST);
}

void resize_gl_viewport(GLFWwindow* window)
{
    int width, height;
    glfwGetWindowSize(window, &width, &height);
    glViewport(0, 0, width, height);
}

void ksa_uniform_mat4(unsigned int program, char* name, float* value)
{
    glUniformMatrix4fv(glGetUniformLocation(program, name), 1, GL_FALSE, value);
}
