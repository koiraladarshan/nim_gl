import ../nim_glpkg/ksa as k
import ../nim_glpkg/glm as m
import shaders as s
import ../nim_glpkg/assimp as a

type 
    pos = object
        x: cfloat
        y: cfloat
        z: cfloat
    
    color = object
        r: cfloat
        g: cfloat
        b: cfloat

type 
    vertex = object
        p: pos
        c: color
    quad = object
        a, b, c, d, e, f : cint


var vao: vao
var vbo: vbo
var vbl: vbl
var pro: cuint
var ibo: ibo

proc init*() : void = 
#    do_the_import_thing("/home/darshan/Documents/projects/nim_gl/res/test.obj")
    var scene : aiScene 
    discard import_file("/home/darshan/Documents/projects/nim_gl/res/test.obj", scene.unsafeAddr)

    echo "from nim(scene): ", sizeof(scene)
    echo "from nim(aiscene)", sizeof(aiScene)
    echo "from nim(ainode)", sizeof(aiNode)
    echo "from nim(aiMesh)", sizeof(aiMesh)
    echo "from nim(aiMaterial)", sizeof(aiMaterial)
    echo "from nim(aiAnimation)", sizeof(aiAnimation)
    echo "from nim(aiTexture)", sizeof(aiTexture)
    echo "from nim(aiLight)", sizeof(aiLight)
    echo "from nim(aiCamera)", sizeof(aiCamera)
    echo "from nim(aiMetadata)", sizeof(aiMetaData)
    echo "from nim(aiString)", sizeof(aiString)
    echo "from nim(aiSkeleton)", sizeof(aiSkeleton)
    echo "from nim(aiNodeAnim)", sizeof(aiNodeAnim)
    echo "from nim(aiMeshAnim)", sizeof(aiMeshAnim)
    echo "from nim(aiMeshMorphAnim)", sizeof(aiMeshMorphAnim)
    echo "from nim(aiFace)", sizeof(aiFace)
    echo "from nim(aiBone)", sizeof(aiBone)
    echo "from nim(aiVertexWeight)", sizeof(aiVertexWeight)
    echo "from nim(aiAABB)", sizeof(aiAABB)
    echo "from nim(aiAnimMesh)", sizeof(aiAnimMesh)
    echo "from nim(aiVector3D)", sizeof(aiVector3D)
    echo "from nim(aiColor4D)", sizeof(aiColor4D)
    echo "from nim(cuint)", sizeof(cuint)
    echo "from nim(cfloat)", sizeof(cfloat)
    echo "from nim(aiSkeletonBone)", sizeof(aiSkeletonBone)

    echo scene.mNumMeshes

    let red : color = color(r: 1.0, g: 0.0, b:0.0)
    let green : color = color(r: 0.0, g: 1.0, b:0.0)
    let blue : color = color(r: 1.0, g: 0.0, b:1.0)
    let pink : color = color(r: 1.0, g: 1.0, b:0.0)

    let vecs: array[8, vertex] = [
        vertex(p: pos(x: 0.5, y: 0.5, z: 0.5), c: red),
        vertex(p: pos(x: 0.5, y: 0.0, z: 0.5), c: green),
        vertex(p: pos(x: 0.5, y: 0.5, z: 0.0), c: blue),
        vertex(p: pos(x: 0.5, y: 0.0, z: 0.0), c: pink),
        vertex(p: pos(x: 0.0, y: 0.5, z: 0.0), c: red),
        vertex(p: pos(x: 0.0, y: 0.0, z: 0.0), c: green),
        vertex(p: pos(x: 0.0, y: 0.5, z: 0.5), c: blue),
        vertex(p: pos(x: 0.0, y: 0.0, z: 0.5), c: pink),
    ]

    let ind: array[6, quad] = [
        quad(a: 0, b: 2, c: 3, d: 0, e: 1, f: 3),
        quad(a: 4, b: 5, c: 3, d: 4, e: 2, f: 3),
        quad(a: 4, b: 5, c: 6, d: 5, e: 6, f: 7),
        quad(a: 6, b: 7, c: 1, d: 6, e: 1, f: 0),
        quad(a: 6, b: 4, c: 2, d: 6, e: 0, f: 2),
        quad(a: 7, b: 5, c: 3, d: 7, e: 1, f: 3)
    ]
    vao.init()
    vbl.init()
    vbl.push(3)
    vbl.push(3)
    ibo.init(data=unsafeAddr(ind[0].a), size=cuint(sizeof(ind)), types=k.GL_DYNAMIC_DRAW)
    vbo.init(data=unsafeAddr(vecs[0]), size=cuint(sizeof(vecs)), types=k.GL_DYNAMIC_DRAW)
    vao.add_buffer(vbo, vbl)
    pro = compile_shaders(s.vnormal_fill(), s.fnormal_fill())

proc draw*() = 
    var eye : vec3 = [(cfloat)1, (cfloat)1, (cfloat) 1]
    var center : vec3 = [(cfloat)0.0, (cfloat)0.0, (cfloat) 0.0]
    var up : vec3 = [(cfloat)0, (cfloat)1, (cfloat) 0]
    var look_at : mat4 = m.lookat(eye, center, up)
    var perspective : mat4 = m.persp(0.7853, 640/480, 0.1, 100)
    var mvp : mat4 = perspective * look_at
    pro.bind_shader()
    k.uniform_mat4(pro, "u_mvp", mvp[0][0].unsafeAddr)
    pro.bind_shader()
    k.draw_elements(6*6, nil)

proc destroy*() = discard