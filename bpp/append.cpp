#include <iostream>
#include <fstream>
using namespace std;
//append file I am the
// 0      1   2 3   4
int main(int argc, char** argv){
  ofstream file;
  file.open(argv[1], ios::app);

  for(int i = 2; i < argc; i++){
    file << string(argv[i]) << " ";
  }
  file << endl;
  file.close();
  return 0;
}
