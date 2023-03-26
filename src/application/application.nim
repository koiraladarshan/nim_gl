import ../nim_glpkg/ksa as k
import ../nim_glpkg/glm as m
import shaders as s
import ../nim_glpkg/assimp as a
import std/macros



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


var indices_to_be_drawn : cint
proc init*() : void = 
    var sceneptr : ptr aiScene
    var mode : ptr model
    var vert : ptr vertex
    sceneptr = import_file("res/test.obj", sceneptr)

    get_models(sceneptr, mode.addr)
    model_to_vertex(mode, vert.addr, 1)

    new_carray(model, models, mode, 3)

    new_carray(aiMesh, meshes, sceneptr[].mMeshes[], sceneptr[].mNumMeshes)
    new_carray(aiVector3D, vertix, meshes[0].mVertices, meshes[0].mNumVertices)
    new_carray(aiFace, faces, meshes[0].mFaces, meshes[0].mNumFaces)

    var indix : seq[cuint]
    indices_to_be_drawn = (cint)models[1].ntris

    
    for i in countup(0, faces_size - 1):
        new_carray(cuint, axx, faces[i].mIndices, faces[i].mNumIndices)
        for j in countup(0, axx_size - 1):
            indix.add(axx[j])

    vao.init()
    vbl.init()
    vbl.push(3)
    vbl.push(3)
    vbl.push(3)
    ibo.init(data=models[1].tris, size=(cuint)(models[1].ntris * (cuint)sizeof(tris)), types=k.GL_DYNAMIC_DRAW)
    #vbo.init(data=models[1].pos, size=(cuint)(models[1].npos * (cuint)sizeof(position)), types=k.GL_DYNAMIC_DRAW)
    vbo.init(data=vert, size=(cuint)(models[1].npos * (cuint)sizeof(vertex)), types=k.GL_DYNAMIC_DRAW)
    vao.add_buffer(vbo, vbl)
    pro = compile_shaders(s.vnormal_fill(), s.fnormal_fill())

proc draw*() = 
    var eye : vec3 = [(cfloat)3, (cfloat)3, (cfloat) 3]
    var center : vec3 = [(cfloat)0.0, (cfloat)0.0, (cfloat) 0.0]
    var up : vec3 = [(cfloat)0, (cfloat)1, (cfloat) 0]
    var look_at : mat4 = m.lookat(eye, center, up)
    var perspective : mat4 = m.persp(0.7853, 640/480, 0.1, 100)
    var mvp : mat4 = perspective * look_at
    pro.bind_shader()
    k.uniform_mat4(pro, "u_mvp", mvp[0][0].unsafeAddr)
    pro.bind_shader()
    k.draw_elements(indices_to_be_drawn * 3, nil)

proc destroy*() = discard