import ../nim_glpkg/ksa as k
import ../nim_glpkg/glm as m
import ../nim_glpkg/assimp as a
import shaders as s
import std/macros

#[
    MACROS
]#

macro new_carray*(typo: untyped, variable: untyped, to: untyped, size: untyped): untyped =
    let lit = ident($`variable` & "_size")
    quote do:
        var `variable` : ptr UncheckedArray[`typo`] = cast[ptr UncheckedArray[`typo`]](`to`)
        var `lit` : cint = (cint)`size`

type
    obj* = object
        name* : cstring
        path* : cstring
        parent* : ptr obj
        vao*: vao
        vbo*: vbo
        vbl*: vbl
        pro*: cuint
        ibo*: ibo
        vert* : ptr vertex
        model* : ptr model
        ntris* : cuint

proc init*(antah: ptr obj, index: cuint) = 
    model_to_vertex(antah.model, antah.vert.addr, index)
    new_carray(model, models, antah.model, 0)
    new_carray(typo = vertex, variable = vertices, to = antah.vert, size = 0)

    antah.ntris = models[index].ntris
    antah.vao.init()
    antah.vbl.init()
    antah.vbl.push(3)
    antah.vbl.push(3)
    antah.vbl.push(3)
    antah.ibo.init(data = models[index].tris, size = (cuint)(models[index].ntris * (cuint)sizeof(tris)), types = k.GL_DYNAMIC_DRAW)

    # HERE IS THE PROBLEM
    antah.vbo.init(data = vertices, size = (cuint)((models[index].npos) * (cuint)sizeof(vertex)), types = k.GL_DYNAMIC_DRAW)
    # HERE IS THE PROBLEM


    antah.vao.add_buffer(antah.vbo, antah.vbl)
    antah.pro = compile_shaders(s.vnormal_fill(), s.fnormal_fill())

proc draw*(antah: obj) =
    k.draw_elements((cint)antah.ntris * 3, nil)

proc destroy*(antah: obj) = discard