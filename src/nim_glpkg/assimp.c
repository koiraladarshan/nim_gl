#include "assimp/cimport.h"
#include "assimp/mesh.h"
#include "assimp/scene.h"
#include "assimp/postprocess.h"
#include <stdio.h>
#include <stdlib.h>

struct Stack
{
  void *data[500];
  int top;
};

struct Stack mem_manage;

void mem_manage_init()
{
  mem_manage.top = 0;
}

void mem_manage_push(void *data)
{
  mem_manage.data[mem_manage.top++] = data;
}

void mem_manage_free()
{
  for (int i = 0; i < mem_manage.top; i++)
  {
    free(mem_manage.data[i]);
  }
}

struct position
{
  float x;
  float y;
  float z;
};

struct tris
{
  unsigned int indices[3];
};

struct model
{
  struct position *v;
  unsigned int npos;
  struct tris *t;
  unsigned int ntris;
  struct position *n;
  unsigned int nnormals;
};

struct vertex
{
  struct position pos;
  struct position color;
  struct position normal;
};

const struct
    aiScene *
    import_file(const char *string, const struct aiScene *scene)
{
  scene = aiImportFile(string,
                       aiProcess_CalcTangentSpace |
                           aiProcess_Triangulate |
                           aiProcess_JoinIdenticalVertices |
                           aiProcess_SortByPType);
  if (!scene)
  {
    printf("%s", aiGetErrorString());
    return 0;
  }
#ifdef DEBUG_ONLY
  printf("Size (from C)(aiscene):%d\n", (int)sizeof(struct aiScene));
  printf("from C(aiscene)%d\n", (int)sizeof(struct aiScene));
  printf("from C(ainode)%d\n", (int)sizeof(struct aiNode));
  printf("from C(aiMesh)%d\n", (int)sizeof(struct aiMesh));
  printf("from C(aiMaterial)%d\n", (int)sizeof(struct aiMaterial));
  printf("from C(aiAnimation)%d\n", (int)sizeof(struct aiAnimation));
  printf("from C(aiTexture)%d\n", (int)sizeof(struct aiTexture));
  printf("from C(aiLight)%d\n", (int)sizeof(struct aiLight));
  printf("from C(aiCamera)%d\n", (int)sizeof(struct aiCamera));
  printf("from C(aiMetadata)%d\n", (int)sizeof(struct aiMetadata));
  printf("from C(aiString)%d\n", (int)sizeof(struct aiString));
  printf("from C(aiSkeleton)%d\n", (int)sizeof(struct aiSkeleton));
  printf("from C(aiNodeAnim)%d\n", (int)sizeof(struct aiNodeAnim));
  printf("from C(aiMeshAnim)%d\n", (int)sizeof(struct aiMeshAnim));
  printf("from C(aiMeshMorphAnim)%d\n", (int)sizeof(struct aiMeshMorphAnim));
  printf("from C(aiFace)%d\n", (int)sizeof(struct aiFace));
  printf("from C(aiBone)%d\n", (int)sizeof(struct aiBone));
  printf("from C(aiVertexWeight)%d\n", (int)sizeof(struct aiVertexWeight));
  printf("from C(aiAABB)%d\n", (int)sizeof(struct aiAABB));
  printf("from C(aiAnimMesh)%d\n", (int)sizeof(struct aiAnimMesh));
  printf("from C(aiVector3D)%d\n", (int)sizeof(struct aiVector3D));
  printf("from C(aiColor4D)%d\n", (int)sizeof(struct aiColor4D));
  printf("from nim(cuint)%d\n", (int)sizeof(unsigned int));
  printf("from nim(cfloat)%d\n", (int)sizeof(float));
  printf("from nim(aiSkeleteonBone)%d\n", (int)sizeof(struct aiSkeletonBone));

  printf("hello world\n");
  printf("FUCKING LIGHTS: %d\n", scene->mNumLights);
  printf("FUCKING MESHEDS: %d\n", scene->mNumMeshes);
  printf("mNumVerts: %d\n", scene->mMeshes[0]->mNumVertices);

  for (int i = 0; i < scene->mMeshes[0]->mNumFaces; i++)
  {
    for (int j = 0; j < scene->mMeshes[0]->mFaces[i].mNumIndices; j++)
    {
      printf("mIndices%d:%d\n", j, scene->mMeshes[0]->mFaces[i].mIndices[j]);
    }
  }
#endif
  return scene;
}

void destroy_file(const struct aiScene *scene)
{
  aiReleaseImport(scene);
}

static int alloc_models(struct aiNode *node, struct model **models)
{
  static int no_of_meshes = 0;
  if (node->mNumMeshes != 0)
  {
    printf("mNumMeshes: %d\n", node->mNumMeshes);
    no_of_meshes += node->mNumMeshes;
  }

  for (int i = 0; i < node->mNumChildren; i++)
  {
    alloc_models(node->mChildren[i], models);
  }
  return no_of_meshes;
}

static void write_models(const struct aiScene *scene, struct aiNode *node, struct model *models)
{
  static int model_index = 0;
  if (node->mNumMeshes != 0)
  {
    printf("mMMM: %d\n", node->mNumMeshes);
    for (int i = 0; i < node->mNumMeshes; i++)
    {
      /*Vertices*/
      int mesh_index = node->mMeshes[i];
      models[model_index].v = (struct position *)malloc(sizeof(struct position) * scene->mMeshes[mesh_index]->mNumVertices);
      models[model_index].npos = scene->mMeshes[mesh_index]->mNumVertices;
      memcpy(models[model_index].v, scene->mMeshes[model_index]->mVertices, sizeof(struct position) * scene->mMeshes[model_index]->mNumVertices);

      /*Indices*/
      models[model_index].t = (struct tris *)malloc(sizeof(struct tris) * scene->mMeshes[mesh_index]->mNumFaces);
      models[model_index].ntris = scene->mMeshes[mesh_index]->mNumFaces;
      /*For Each Face*/
      int index_index = 0;
      for (int ii = 0; ii < scene->mMeshes[mesh_index]->mNumFaces; ii++)
      {
        /*For Each Indices*/
        for (int j = 0; j < scene->mMeshes[mesh_index]->mFaces[ii].mNumIndices; j++)
        {
          models[model_index].t[ii].indices[j] = scene->mMeshes[mesh_index]->mFaces[ii].mIndices[j];
          index_index++;
        }
      }

      /*Normals*/
      models[model_index].n = (struct position *)malloc(sizeof(struct position) * scene->mMeshes[mesh_index]->mNumVertices);
      models[model_index].nnormals = scene->mMeshes[mesh_index]->mNumVertices;
      memcpy(models[model_index].n, scene->mMeshes[model_index]->mNormals, sizeof(struct position) * scene->mMeshes[model_index]->mNumVertices);
    }
    model_index++;
  }

  for (int i = 0; i < node->mNumChildren; i++)
  {
    write_models(scene, node->mChildren[i], models);
  }
}

void get_models(const struct aiScene *scene, struct model **models)
{
  struct aiNode *node = scene->mRootNode;
  int number_of_models = alloc_models(node, models);
  (*models) = (struct model *)malloc(number_of_models * sizeof(struct model));
  write_models(scene, node, *models);

  for (int i = 0; i < (*models)[0].npos; i++)
  {
    //   printf("x:%f, y:%f, z:%f\n", (*models)[0].v[i].x, (*models)[0].v[i].y, (*models)[0].v[i].z);
  }
}

void model_to_vertex(struct model *themodel, struct vertex **thevertices, int index)
{
  (*thevertices) = (struct vertex *)malloc(themodel[index].npos * sizeof(struct vertex));
  for (int i = 0; i < themodel[index].npos; i++)
  {
    (*thevertices)[i] = (struct vertex){
        (struct position){themodel[index].v[i].x, themodel[index].v[i].y, themodel[index].v[i].z},
        (struct position){0.0, 1.0, 0.0},
        (struct position){themodel[index].n[i].x, themodel[index].n[i].y, themodel[index].n[i].z}};
  }
}