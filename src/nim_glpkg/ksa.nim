{.passl: "`pkg-config --libs glew glfw3 assimp` -Wall".}
{.compile:"ksa.c".}

import glfw
#[
    ALL CONSTANTS
]#

const GL_UNSIGNED_INT* : cuint= 0x1405
const GL_FLOAT* : cuint = 0x1406
const GL_DYNAMIC_DRAW* : cuint = 0x88E8

#[
    Some Macros and Templates
]#

#[
    These are all initialzation stuffs
]#

proc init_glew*() : cint {.importc.}

proc clear_color*(r, g, b, a: cfloat) {.importc.}

proc clear*() {.importc.}

proc draw_arrays*(first: cuint, count: cuint) {.importc.}

proc do_glfw_init*() {.importc.}

proc debug_callback_setup*() {.importc.}

proc compile_shaders*(vshader_source: cstring, fshader_source: cstring) : cuint {.importc.}

proc bind_shader*(program : cuint) {.importc.}

proc setup_gl_viewport*(x: cint = 0, y: cint = 0, width : cint = 640, height: cint = 480) : void {.importc.}

proc resize_gl_viewport*(window: GLFWwindow) {.importc.}

proc draw_elements*(count: cint, data: pointer) {.importc.}
#[
    VertexBuffers
]#

type 
    vbo_org = object
        id*: cuint
    vbo* = ptr vbo_org

proc init*(vbuffer: var vbo, data: pointer, size: cuint, types: cuint) {.importc:"ksa_vbuffer_init".}
proc kbind*(vbuffer: var vbo) {.importc: "ksa_vbuffer".}
proc ubind*(vbuffer: var vbo) {.importc: "ksa_vbuffer_unbind".}
proc destroy*(vbuffer: var vbo) {.importc: "ksa_vbuffer_destroy".}

type
    vbe_org = object
        types*: cuint
        count*: cuint
        normalized*: cuint
    vbe* = ptr vbe_org

type 
    vbl_org = object
        elements*: array[0..50, vbe_org]
        stride*: cuint
        index*: cuint
    vbl* = ptr vbl_org

proc init*(vbuffer_layout: var vbl) {.importc: "ksa_vbuffer_layout_init".}
proc push*(vbuffer_layout: var vbl, count: cuint) {.importc: "ksa_vbuffer_layout_push".}

type
    vao_org* = object
       id*: cuint 
    vao* = ptr vao_org

proc init*(varray: var vao) {.importc: "ksa_varray_init".}
proc kbind*(varray: var vao) {.importc: "ksa_varray_bind".}
proc add_buffer*(varray: var vao, vbuffer: var vbo, vbuffer_layout:var vbl) {.importc: "ksa_varray_add_buffer".}
proc ubind*(varray: var vao) {.importc: "ksa_varray_unbind".}

type
    shader_files* = ptr object
        vertex*: ptr cchar
        fragment*: ptr cchar
        geometry*: ptr cchar

type 
    shader* = ptr object
        program_id: cuint
        vshader_id: cuint
        fshader_id: cuint
        gshader_id: cuint
        vshader_path: ptr cchar
        fshader_path: ptr cchar
        gshader_path: ptr cchar

proc get*(s:var shader, sf: shader_files) {.importc:"ksa_shader_get".}
proc init*(s:var shader, sf: shader_files) {.importc: "ksa_shader_init".}
proc destroy*(s:var shader, sf: shader_files) {.importc: "ksa_shader_destory".}
proc kbind*(s:var shader) {.importc: "ksa_shader_use".}

type 
    ibo* = ptr object
        id*: cuint

proc init*(ibuffer:var ibo, data: pointer, size: cuint, types: cuint) {.importc:"ksa_ibuffer_init".}
proc kbind*(ibuffer: var ibo) {.importc: "ksa_ibuffer_bind".}
proc ubind*(ibuffer: var ibo) {.importc: "ksa_ibuffer_unbind".}
proc destory*(ibuffer: var ibo) {.importc: "ksa_ibuffer_destroy".}

proc uniform_mat4*(program: cuint, name: cstring, value: ptr cfloat) {.importc:"ksa_uniform_mat4".}