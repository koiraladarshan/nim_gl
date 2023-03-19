import ../nim_glpkg/ksa as k
import ../nim_glpkg/glm as m
import shaders as s


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
    var eye : vec3 = [(cfloat)0.5, (cfloat)0.2, (cfloat) 0.4]
    var center : vec3 = [(cfloat)0.5, (cfloat)0.2, (cfloat) 0.4]
    var up : vec3 = [(cfloat)0.5, (cfloat)0.2, (cfloat) 0.4]
    var look_at : mat4 = m.lookat(eye, center, up)
    var perspective : mat4 = m.persp(0.42, 640/480, 0.1, 100)
    pro.bind_shader()
    k.draw_elements(6*6, nil)

proc destroy*() = discard