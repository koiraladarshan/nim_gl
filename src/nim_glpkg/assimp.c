#include <assimp/cimport.h>        // Plain-C interface
#include <assimp/scene.h>        // Output data structure
#include <assimp/postprocess.h>    // Post processing flags
#include <stdio.h>


int import_file(const char* string, const struct aiScene* scene) {
  // Start the import on the given file with some example postprocessing
  // Usually - if speed is not the most important aspect for you - you'll t
  // probably to request more postprocessing than we do in this example.
  scene = aiImportFile( "/home/darshan/Documents/projects/nim_gl/res/test.obj",
    aiProcess_CalcTangentSpace       |
    aiProcess_Triangulate            |
    aiProcess_JoinIdenticalVertices  |
    aiProcess_SortByPType);

  // If the import failed, report it
  if(!scene) {
    printf("%s", aiGetErrorString());
    return 0;
  }

  printf("hello world\n");
  printf("FUCKING LIGHTS: %d\n", scene->mNumLights);
  printf("FUCKING MESHEDS: %d\n", scene->mNumMeshes);
  // Now we can access the file's contents
//  DoTheSceneProcessing( scene);

  // We're done. Release all resources associated with this import
// aiReleaseImport( scene);
  return 1;
}
