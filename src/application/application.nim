import ../nim_glpkg/ksa as k
import ../nim_glpkg/glm as m
import shaders as s
import ../nim_glpkg/assimp as a
import std/macros
import models as models


var vao: vao
var vbo: vbo
var vbl: vbl
var pro: cuint
var ibo: ibo


macro new_carray(typo: untyped, vari: untyped, to: untyped, size: untyped): untyped =
    let lit = ident($`vari` & "_size")
    quote do:
        var `vari` : ptr UncheckedArray[`typo`] = cast[ptr UncheckedArray[`typo`]](`to`)
        var `lit` : cint = (cint)`size`


var theobj : models.obj
proc init*() : void = 
    var sceneptr : ptr aiScene
    sceneptr = import_file("res/test.obj", sceneptr)
    get_models(sceneptr, theobj.model.addr)
    theobj.init(1)


proc draw*() = 
    var eye : vec3 = [(cfloat)3, (cfloat)3, (cfloat) 3]
    var center : vec3 = [(cfloat)0.0, (cfloat)0.0, (cfloat) 0.0]
    var up : vec3 = [(cfloat)0, (cfloat)1, (cfloat) 0]
    var look_at : mat4 = m.lookat(eye, center, up)
    var perspective : mat4 = m.persp(0.7853, 640/480, 0.1, 100)
    var mvp : mat4 = perspective * look_at
    theobj.pro.bind_shader()
    k.uniform_mat4(theobj.pro, "u_mvp", mvp[0][0].unsafeAddr)
    theobj.pro.bind_shader()
    k.draw_elements((cint)theobj.ntris * 3, nil)

proc destroy*() = discard