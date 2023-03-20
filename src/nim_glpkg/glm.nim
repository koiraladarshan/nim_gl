{.passl: "-lm"}
{.compile:"cglm.c"}
import std/macros

template vec(n: untyped): untyped =
    type
        `vec n`*{.inject.} = array[n, cfloat]
        `mat n`*{.inject.} = array[n, `vec n`]
        `vec n p`*{.inject.} = ptr `vec n`
        `mat n p`*{.inject.} = ptr `mat n`
    
vec(2)
vec(3)
vec(4)

#[
    RAW FUNCTIONS
]#
const libHeader* = "nim_glpkg/cglm/cglm.h"

proc glm_ortho(left: cfloat, right: cfloat, bottom: cfloat, top: cfloat, nearz: cfloat, farz: cfloat, dest: ptr vec4) {.importc:"glm_ortho", header:libHeader.}

proc glm_perspective(fovy: cfloat, aspect: cfloat, nearz: cfloat, farz: cfloat, dest: ptr vec4) {.importc:"glm_perspective", header:libHeader.}

proc glm_lookat(eye: ptr cfloat, center: ptr cfloat, up: ptr cfloat, dest: ptr vec4) {.importc:"glm_lookat", header:libHeader.}

proc glm_mat4_mul(m1: ptr vec4, m2: ptr vec4, dest: ptr vec4) {.importc: "glm_mat4_mul", header: libHeader.}

proc ortho*(left, right, bottom, top, near, far: cfloat) : mat4 =
    var mat : mat4
    glm_ortho(left, right, bottom, top, near, far, mat[0].addr)
    result = mat


proc persp*(fovy: cfloat, aspect: cfloat, nearz: cfloat, farz: cfloat) : mat4 =
    var mat : mat4
    glm_perspective(fovy, aspect, nearz, farz, mat[0].addr)
    result = mat

proc lookat*(eye: vec3, center: vec3, up: vec3) : mat4 = 
    var mat : mat4
    glm_lookat(eye[0].unsafeAddr, center[0].unsafeAddr, up[0].unsafeAddr, mat[0].unsafeAddr)
    result = mat

proc `*`*(m1: mat4, m2: mat4) : mat4 =
    var mat : mat4
    glm_mat4_mul(m1[0].unsafeAddr, m2[0].unsafeAddr, mat[0].addr)
    result = mat