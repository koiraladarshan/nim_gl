import std/macros

# All macros
macro `~@`*(arg: untyped) : untyped =
  let name = newLit(arg.treeRepr)
  result = quote do:
    if `arg` == 0:
      echo "Failed Execution"
      echo `name`
    else:
      discard

# Required Dynamic Libraries
when defined(Windows):
  const libName* = "glfw3.dll"
elif defined(Linux):
  const libName* = "libglfw.so"
elif defined(MacOsX):
  const libName* = "libglfw.dylib"

# Operators
proc `!`*(input: cint) : bool = 
  if input == 0 : 
    result = true 
  else: 
    result = false


type 
    GLFWwindow* = ptr object
    GLFWmonitor* = ptr object

proc init*() : cint {.importc : "glfwInit", dynlib:libName.}
proc create_window*(width: cint = 640, height:cint = 480, title: cstring = "New Window", monitor: GLFWmonitor = nil, share: GLFWwindow = nil) : GLFWwindow {.importc : "glfwCreateWindow", dynlib:libName.}
proc make_context_current*(window: GLFWwindow) {.importc: "glfwMakeContextCurrent", dynlib:libName.}
proc window_should_close*(window: GLFWwindow) : cint {.importc: "glfwWindowShouldClose", dynlib:libName.}
proc poll_events*() {.importc: "glfwPollEvents", dynlib:libName.}
proc terminate*() {.importc: "glfwTerminate", dynlib:libName.}
proc swap_buffers*(window: GLFWwindow) : cint {.importc: "glfwSwapBuffers", dynlib:libName.}