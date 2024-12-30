from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout
import os
import requests
import zipfile

class MyProjectConan(ConanFile):
    name = "myproject"
    version = "1.0.0"
    settings = "os", "arch", "compiler", "build_type"
    generators = "CMakeDeps"

    def layout(self):
        cmake_layout(self)
    
    def generate(self):
        tc = CMakeToolchain(self)
        tc.generator = "Ninja"  # Burada Ninja generator'ını seçiyoruz
        tc.generate()

    def source(self):
        # VTK zip dosyasını GitHub'dan indir
        vtk_url = "https://github.com/yarenakin/MyConanCenter/raw/main/install.zip"
        vtk_zip_path = os.path.join(self.source_folder, "install.zip")
        self.output.info(f"Downloading VTK from {vtk_url}")
        with open(vtk_zip_path, "wb") as f:
            response = requests.get(vtk_url)
            response.raise_for_status()
            f.write(response.content)

        # Zip dosyasını çıkar
        vtk_extract_path = os.path.join(self.source_folder, "tools/vtk").replace("\\", "/")
        self.output.info(f"Extracting VTK to {vtk_extract_path}")
        with zipfile.ZipFile(vtk_zip_path, "r") as zip_ref:
            zip_ref.extractall(vtk_extract_path)

        # Geçici zip dosyasını sil
        os.remove(vtk_zip_path)

    def build(self):
        # CMake yapılandırma ve derleme işlemi
        cmake = CMake(self)
        # CMake'i Emscripten toolchain dosyası ile çalıştır
        cmake.configure( build_script_folder=self.folders.source_folder,
        variables={
        "CMAKE_TOOLCHAIN_FILE": os.path.join(self.build_folder, "Release","generators", "conan_toolchain.cmake")
    })
        cmake.build()
    
