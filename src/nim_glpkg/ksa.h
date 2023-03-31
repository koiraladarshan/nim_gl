#pragma once
#ifdef KSAGL_IMPLEMENTATION_OPENGL
#include <GL/glew.h>
#include <stdlib.h>
#include <stdio.h>
#endif

/* Vertex Buffers*/
typedef struct
{
	unsigned int rendererId;
} ksa_vbuffer;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_vbuffer_init(ksa_vbuffer *vbuffer, const void *data, unsigned int size, unsigned int type)
{
	glGenBuffers(1, &vbuffer->rendererId);
	glBindBuffer(GL_ARRAY_BUFFER, vbuffer->rendererId);
	glBufferData(GL_ARRAY_BUFFER, size, data, type);
}

void ksa_vbuffer_bind(ksa_vbuffer *vbuffer)
{
	glBindBuffer(GL_ARRAY_BUFFER, vbuffer->rendererId);
}

void ksa_vbuffer_unbind(ksa_vbuffer *vbuffer)
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void ksa_vbuffer_destroy(ksa_vbuffer *vbuffer)
{
	glDeleteBuffers(1, &vbuffer->rendererId);
}
#endif

/* Vertex Buffer Elements and Layouts*/

typedef struct ksa_vbuffer_element
{
	unsigned int type;
	unsigned int count;
	unsigned int normalized;
} ksa_vbuffer_element;

typedef struct ksa_vbuffer_layout
{
	ksa_vbuffer_element elements[50];
	unsigned int stride;
	int index;
} ksa_vbuffer_layout;

typedef struct ksa_varray
{
	unsigned int rendererID;
} ksa_varray;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_vbuffer_layout_init(ksa_vbuffer_layout *layout)
{
	layout->stride = 0;
	layout->index = 0;
}

void ksa_vbuffer_layout_push(ksa_vbuffer_layout *layout, unsigned int count)
{
	layout->elements[layout->index++] = (ksa_vbuffer_element){GL_FLOAT, count, GL_FALSE};
	layout->stride += count * sizeof(GL_FLOAT);
}

void ksa_varray_init(ksa_varray *varray)
{
	glGenVertexArrays(1, &varray->rendererID);
	glBindVertexArray(varray->rendererID);
}

void ksa_varray_bind(ksa_varray *varray)
{
	glBindVertexArray(varray->rendererID);
}

void ksa_varray_add_buffer(ksa_varray *varray, ksa_vbuffer *vbuffer, ksa_vbuffer_layout *layout)
{
	ksa_varray_bind(varray);
	ksa_vbuffer_bind(vbuffer);
	unsigned int _offset = 0;
	for (unsigned int _i = 0; _i < layout->index; _i++)
	{
		glEnableVertexAttribArray(_i);
		glVertexAttribPointer(_i,
							  layout->elements[_i].count,
							  layout->elements[_i].type,
							  layout->elements[_i].normalized,
							  layout->stride,
							  (void *)_offset);
		_offset += layout->elements[_i].count * sizeof(GL_FLOAT);
	}
}

void ksa_varray_unbind(ksa_varray *varray)
{
	glBindVertexArray(0);
}
#endif

/* Shaders */

typedef struct ksa_shaderfiles
{
	char *vertex;
	char *fragment;
	char *geometry;
} ksa_shaderfiles;

typedef struct ksa_shader
{
	unsigned int programId;
	unsigned int vshaderId;
	unsigned int fshaderId;
	unsigned int gshaderId;
	const char *vshaderPath;
	const char *fshaderPath;
	const char *gshaderPath;
} ksa_shader;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_shader_get(ksa_shader *shader, ksa_shaderfiles *files)
{
	FILE *_vshaderFile = NULL;
	FILE *_fshaderFile = NULL;
	FILE *_gshaderFile = NULL;
	size_t _vshaderSize = 0;
	size_t _fshaderSize = 0;
	size_t _gshaderSize = 0;

	/*VShader*/
	_vshaderFile = fopen(shader->vshaderPath, "rb");
	if (_vshaderFile != NULL)
	{
		fseek(_vshaderFile, 0, SEEK_END);
		_vshaderSize = ftell(_vshaderFile);
		fseek(_vshaderFile, 0, SEEK_SET);
		files->vertex = (char *)malloc(_vshaderSize + 1);
		fread(files->vertex, 1, _vshaderSize, _vshaderFile);
		files->vertex[_vshaderSize] = 0;
		fclose(_vshaderFile);
	}
	else
	{
		printf("No Vertex Shader:\n Using Default\n");
	}

	/*FShader*/
	_fshaderFile = fopen(shader->fshaderPath, "rb");
	if (_fshaderFile != NULL)
	{
		fseek(_fshaderFile, 0, SEEK_END);
		_fshaderSize = ftell(_fshaderFile);
		fseek(_fshaderFile, 0, SEEK_SET);
		files->fragment = (char *)malloc(_fshaderSize + 1);
		fread(files->fragment, 1, _fshaderSize, _fshaderFile);
		files->fragment[_fshaderSize] = 0;
		fclose(_fshaderFile);
	}
	else
	{
		printf("No Pixel Shader:\n Using Default\n");
	}

	/*GShader*/
	if (shader->gshaderPath != NULL)
	{
		_gshaderFile = fopen(shader->gshaderPath, "rb");
		if (_gshaderFile != NULL)
		{
			fseek(_gshaderFile, 0, SEEK_END);
			_gshaderSize = ftell(_gshaderFile);
			fseek(_gshaderFile, 0, SEEK_SET);
			files->geometry = (char *)malloc(_gshaderSize + 1);
			fread(files->geometry, 1, _gshaderSize, _gshaderFile);
			files->geometry[_gshaderSize] = 0;
			fclose(_gshaderFile);
		}
		else
		{
			printf("No Geometry Shader:\n Using Default\n");
		}
	}
	printf("%s", files->vertex);
	printf("%s", files->fragment);
	printf("%s", files->geometry);
}

void ksa_shader_init(ksa_shader *shader, ksa_shaderfiles *files)
{
	// compileShader
	shader->programId = glCreateProgram();

	shader->vshaderId = glCreateShader(GL_VERTEX_SHADER);
	shader->fshaderId = glCreateShader(GL_FRAGMENT_SHADER);
	if (shader->gshaderPath != NULL)
		shader->gshaderId = glCreateShader(GL_GEOMETRY_SHADER);

	glShaderSource(shader->vshaderId, 1, &files->vertex, NULL);
	glShaderSource(shader->fshaderId, 1, &files->fragment, NULL);
	if (shader->gshaderPath != NULL)
	{
		glShaderSource(shader->gshaderId, 1, &files->geometry, NULL);
	}

	glCompileShader(shader->vshaderId);
	glCompileShader(shader->fshaderId);
	if (shader->gshaderPath != NULL)
	{
		glCompileShader(shader->gshaderId);
	}

	glAttachShader(shader->programId, shader->vshaderId);
	glAttachShader(shader->programId, shader->fshaderId);
	if (shader->gshaderPath != NULL)
	{
		glAttachShader(shader->programId, shader->gshaderId);
	}

	glLinkProgram(shader->programId);
	glValidateProgram(shader->programId);

	glDeleteShader(shader->vshaderId);
	glDeleteShader(shader->fshaderId);
	if (shader->gshaderPath != NULL)
	{
		glDeleteShader(shader->gshaderId);
	}
}

unsigned int ksa_create_shader(ksa_shaderfiles *files)
{
	return 0;
}

void ksa_shader_destroy(ksa_shader *shader, ksa_shaderfiles *files)
{
	free(shader);
	free(files);
}

void ksa_shader_use(ksa_shader *shader)
{
	glUseProgram(shader->programId);
}

#endif

/* Index Buffer */
typedef struct
{
	unsigned int rendererId;
} ksa_ibuffer;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_ibuffer_init(ksa_ibuffer *ibuffer, const void *data, unsigned int size, unsigned int type)
{
	glGenBuffers(1, &ibuffer->rendererId);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibuffer->rendererId);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, type);
}

void ksa_ibuffer_bind(ksa_ibuffer *ibuffer)
{
	glBindBuffer(GL_ARRAY_BUFFER, ibuffer->rendererId);
}

void ksa_ibuffer_unbind(ksa_ibuffer *ibuffer)
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void ksa_ibuffer_destroy(ksa_ibuffer *ibuffer)
{
	glDeleteBuffers(1, &ibuffer->rendererId);
}
#endif

/* Render Buffer */
typedef struct
{
	unsigned int rendererId;
} ksa_rbuffer;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_rbuffer_init(ksa_rbuffer *fbuffer, unsigned int _storagex, unsigned int _storagey)
{
	glGenRenderbuffers(1, &fbuffer->rendererId);
	glBindRenderbuffer(GL_RENDERBUFFER, fbuffer->rendererId);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, _storagex, _storagey);
	glBindRenderbuffer(GL_RENDERBUFFER, 0);
	//	glBufferData(GL_RENDERBUFFER, size, data, type);
}

void ksa_rbuffer_bind(ksa_rbuffer *fbuffer)
{
	glBindRenderbuffer(GL_RENDERBUFFER, fbuffer->rendererId);
}

void ksa_rbuffer_unbind(ksa_rbuffer *fbuffer)
{
	glBindBuffer(GL_RENDERBUFFER, 0);
}

void ksa_rbuffer_destroy(ksa_rbuffer *fbuffer)
{
	glDeleteBuffers(1, &fbuffer->rendererId);
}
#endif

/* Frame Buffer */
typedef struct
{
	unsigned int rendererId;
} ksa_fbuffer;

#ifdef KSAGL_IMPLEMENTATION_OPENGL
void ksa_fbuffer_init(ksa_fbuffer *fbuffer, const void *data, unsigned int size, unsigned int type)
{
	glGenFramebuffers(1, &fbuffer->rendererId);
	glBindFramebuffer(GL_FRAMEBUFFER, fbuffer->rendererId);
}

void ksa_fbuffer_bind(ksa_fbuffer *fbuffer)
{
	glBindFramebuffer(GL_FRAMEBUFFER, fbuffer->rendererId);
}

void ksa_fbuffer_unbind(ksa_fbuffer *fbuffer)
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void ksa_fbuffer_destroy(ksa_fbuffer *fbuffer)
{
	glDeleteBuffers(1, &fbuffer->rendererId);
}
#endif
