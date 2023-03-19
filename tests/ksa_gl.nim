when defined(KSAGL_IMPLEMENTATION_OPENGL):
  discard
##  Vertex Buffers

type
  ksa_vbuffer* {.bycopy.} = object
    rendererId*: cuint


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksa_vbuffer_init*(vbuffer: ptr ksa_vbuffer; data: pointer; size: cuint;
                        `type`: cuint) =
    glGenBuffers(1, addr(vbuffer.rendererId))
    glBindBuffer(GL_ARRAY_BUFFER, vbuffer.rendererId)
    glBufferData(GL_ARRAY_BUFFER, size, data, `type`)

  proc ksa_vbuffer_bind*(vbuffer: ptr ksa_vbuffer) =
    glBindBuffer(GL_ARRAY_BUFFER, vbuffer.rendererId)

  proc ksa_vbuffer_unbind*(vbuffer: ptr ksa_vbuffer) =
    glBindBuffer(GL_ARRAY_BUFFER, 0)

  proc ksa_vbuffer_destroy*(vbuffer: ptr ksa_vbuffer) =
    glDeleteBuffers(1, addr(vbuffer.rendererId))

##  Vertex Buffer Elements and Layouts

type
  ksa_vbuffer_element* {.bycopy.} = object
    `type`*: cuint
    count*: cuint
    normalized*: cuint

  ksa_vbuffer_layout* {.bycopy.} = object
    elements*: array[50, ksa_vbuffer_element]
    stride*: cuint
    index*: cint

  ksa_varray* {.bycopy.} = object
    rendererID*: cuint


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksaVBufferElementGetSize*(`type`: cuint): cuint =
    case `type`
    of GL_FLOAT:
      return 4
    of GL_UNSIGNED_INT:
      return 4
    of GL_UNSIGNED_BYTE:
      return 4
    return 0

  proc ksa_vbuffer_layout_push*(layout: ptr ksa_vbuffer_layout; count: cuint) =
    ## !!!Ignored construct:  layout -> elements [ layout -> index ++ ] = ( ksa_vbuffer_element ) { GL_FLOAT , count , GL_FALSE } ;
    ## Error: expected ';'!!!
    inc(layout.stride, count * sizeof((GL_FLOAT)))

  proc ksa_varray_init*(varray: ptr ksa_varray) =
    glGenVertexArrays(1, addr(varray.rendererID))
    glBindVertexArray(varray.rendererID)

  proc ksa_varray_bind*(varray: ptr ksa_varray) =
    glBindVertexArray(varray.rendererID)

  proc ksa_varray_add_buffer*(varray: ptr ksa_varray; vbuffer: ptr ksa_vbuffer;
                             layout: ptr ksa_vbuffer_layout) =
    ksa_varray_bind(varray)
    ksa_vbuffer_bind(vbuffer)
    var _offset: cuint = 0
    var _i: cuint = 0
    while _i < layout.index:
      glEnableVertexAttribArray(_i)
      glVertexAttribPointer(_i, layout.elements[_i].count,
                            layout.elements[_i].`type`,
                            layout.elements[_i].normalized, layout.stride,
                            cast[pointer](_offset))
      inc(_offset, layout.elements[_i].count * sizeof((GL_FLOAT)))
      inc(_i)

  proc ksa_varray_unbind*(varray: ptr ksa_varray) =
    glBindVertexArray(0)

##  Shaders

type
  ksa_shaderfiles* {.bycopy.} = object
    vertex*: cstring
    fragment*: cstring
    geometry*: cstring

  ksa_shader* {.bycopy.} = object
    programId*: cuint
    vshaderId*: cuint
    fshaderId*: cuint
    gshaderId*: cuint
    vshaderPath*: cstring
    fshaderPath*: cstring
    gshaderPath*: cstring


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksa_shader_get*(shader: ptr ksa_shader; files: ptr ksa_shaderfiles) =
    var _vshaderFile: ptr FILE = nil
    var _fshaderFile: ptr FILE = nil
    var _gshaderFile: ptr FILE = nil
    var _vshaderSize: csize_t = 0
    var _fshaderSize: csize_t = 0
    var _gshaderSize: csize_t = 0
    ## VShader
    fopen_s(addr(_vshaderFile), shader.vshaderPath, "rb")
    if _vshaderFile != nil:
      fseek(_vshaderFile, 0, SEEK_END)
      _vshaderSize = ftell(_vshaderFile)
      fseek(_vshaderFile, 0, SEEK_SET)
      files.vertex = cast[cstring](malloc(_vshaderSize + 1))
      fread(files.vertex, 1, _vshaderSize, _vshaderFile)
      files.vertex[_vshaderSize] = 0
      fclose(_vshaderFile)
    else:
      printf("No Vertex Shader:\n Using Default\n")
    ## FShader
    fopen_s(addr(_fshaderFile), shader.fshaderPath, "rb")
    if _fshaderFile != nil:
      fseek(_fshaderFile, 0, SEEK_END)
      _fshaderSize = ftell(_fshaderFile)
      fseek(_fshaderFile, 0, SEEK_SET)
      files.fragment = cast[cstring](malloc(_fshaderSize + 1))
      fread(files.fragment, 1, _fshaderSize, _fshaderFile)
      files.fragment[_fshaderSize] = 0
      fclose(_fshaderFile)
    else:
      printf("No Pixel Shader:\n Using Default\n")
    ## GShader
    if shader.gshaderPath != nil:
      fopen_s(addr(_gshaderFile), shader.gshaderPath, "rb")
      if _gshaderFile != nil:
        fseek(_gshaderFile, 0, SEEK_END)
        _gshaderSize = ftell(_gshaderFile)
        fseek(_gshaderFile, 0, SEEK_SET)
        files.geometry = cast[cstring](malloc(_gshaderSize + 1))
        fread(files.geometry, 1, _gshaderSize, _gshaderFile)
        files.geometry[_gshaderSize] = 0
        fclose(_gshaderFile)
      else:
        printf("No Geometry Shader:\n Using Default\n")
    printf("%s", files.vertex)
    printf("%s", files.fragment)
    printf("%s", files.geometry)

  proc ksa_shader_init*(shader: ptr ksa_shader; files: ptr ksa_shaderfiles) =
    ##  compileShader
    shader.programId = glCreateProgram()
    shader.vshaderId = glCreateShader(GL_VERTEX_SHADER)
    shader.fshaderId = glCreateShader(GL_FRAGMENT_SHADER)
    if shader.gshaderPath != nil:
      shader.gshaderId = glCreateShader(GL_GEOMETRY_SHADER)
    glShaderSource(shader.vshaderId, 1, addr(files.vertex), nil)
    glShaderSource(shader.fshaderId, 1, addr(files.fragment), nil)
    if shader.gshaderPath != nil:
      glShaderSource(shader.gshaderId, 1, addr(files.geometry), nil)
    glCompileShader(shader.vshaderId)
    glCompileShader(shader.fshaderId)
    if shader.gshaderPath != nil:
      glCompileShader(shader.gshaderId)
    glAttachShader(shader.programId, shader.vshaderId)
    glAttachShader(shader.programId, shader.fshaderId)
    if shader.gshaderPath != nil:
      glAttachShader(shader.programId, shader.gshaderId)
    glLinkProgram(shader.programId)
    glValidateProgram(shader.programId)
    glDeleteShader(shader.vshaderId)
    glDeleteShader(shader.fshaderId)
    if shader.gshaderPath != nil:
      glDeleteShader(shader.gshaderId)

  proc ksa_create_shader*(files: ptr ksa_shaderfiles): cuint =
    return 0

  proc ksa_shader_destroy*(shader: ptr ksa_shader; files: ptr ksa_shaderfiles) =
    free(shader)
    free(files)

  proc ksa_shader_use*(shader: ptr ksa_shader) =
    glUseProgram(shader.programId)

##  Index Buffer

type
  ksa_ibuffer* {.bycopy.} = object
    rendererId*: cuint


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksa_ibuffer_init*(ibuffer: ptr ksa_ibuffer; data: pointer; size: cuint;
                        `type`: cuint) =
    glGenBuffers(1, addr(ibuffer.rendererId))
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibuffer.rendererId)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, `type`)

  proc ksa_ibuffer_bind*(ibuffer: ptr ksa_ibuffer) =
    glBindBuffer(GL_ARRAY_BUFFER, ibuffer.rendererId)

  proc ksa_ibuffer_unbind*(ibuffer: ptr ksa_ibuffer) =
    glBindBuffer(GL_ARRAY_BUFFER, 0)

  proc ksa_ibuffer_destroy*(ibuffer: ptr ksa_ibuffer) =
    glDeleteBuffers(1, addr(ibuffer.rendererId))

##  Render Buffer

type
  ksa_rbuffer* {.bycopy.} = object
    rendererId*: cuint


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksa_rbuffer_init*(fbuffer: ptr ksa_rbuffer; _storagex: cuint; _storagey: cuint) =
    glGenRenderbuffers(1, addr(fbuffer.rendererId))
    glBindRenderbuffer(GL_RENDERBUFFER, fbuffer.rendererId)
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, _storagex,
                          _storagey)
    glBindRenderbuffer(GL_RENDERBUFFER, 0)
    ## 	glBufferData(GL_RENDERBUFFER, size, data, type);

  proc ksa_rbuffer_bind*(fbuffer: ptr ksa_rbuffer) =
    glBindRenderbuffer(GL_RENDERBUFFER, fbuffer.rendererId)

  proc ksa_rbuffer_unbind*(fbuffer: ptr ksa_rbuffer) =
    glBindBuffer(GL_RENDERBUFFER, 0)

  proc ksa_rbuffer_destroy*(fbuffer: ptr ksa_rbuffer) =
    glDeleteBuffers(1, addr(fbuffer.rendererId))

##  Frame Buffer

type
  ksa_fbuffer* {.bycopy.} = object
    rendererId*: cuint


when defined(KSAGL_IMPLEMENTATION_OPENGL):
  proc ksa_fbuffer_init*(fbuffer: ptr ksa_fbuffer; data: pointer; size: cuint;
                        `type`: cuint) =
    glGenFramebuffers(1, addr(fbuffer.rendererId))
    glBindFramebuffer(GL_FRAMEBUFFER, fbuffer.rendererId)

  proc ksa_fbuffer_bind*(fbuffer: ptr ksa_fbuffer) =
    glBindFramebuffer(GL_FRAMEBUFFER, fbuffer.rendererId)

  proc ksa_fbuffer_unbind*(fbuffer: ptr ksa_fbuffer) =
    glBindFramebuffer(GL_FRAMEBUFFER, 0)

  proc ksa_fbuffer_destroy*(fbuffer: ptr ksa_fbuffer) =
    glDeleteBuffers(1, addr(fbuffer.rendererId))
