cmake_minimum_required(VERSION 3.30)
project(MyWasmModule)

# Conan bağımlılıkları
include(${CMAKE_BINARY_DIR}/Release/generators/conan_toolchain.cmake)

# VTK'nın indirildiği ve çıkarıldığı dizini ayarla
set(VTK_DIR "${CMAKE_SOURCE_DIR}/tools/vtk/install/lib/cmake/vtk-9.4")

# EMSCRIPTEN kontrolü
if (NOT EMSCRIPTEN)
  message(FATAL_ERROR "This project needs to be built with Emscripten")
endif()

# VTK bağımlılıklarını tanımlayın
find_package(VTK REQUIRED COMPONENTS
 FiltersSources
  RenderingOpenGL2
  RenderingCore
  InteractionStyle
  RenderingContextOpenGL2
  RenderingFreeType
  RenderingUI
)
include_directories(${VTK_INCLUDE_DIRS})
if (NOT VTK_FOUND)
  message(FATAL_ERROR "VTK not found!")
endif()

# Derlenecek hedef dosya
add_executable(MyWasmModule main.cpp)

# VTK kütüphanelerini bağla
target_link_libraries(MyWasmModule PRIVATE ${VTK_LIBRARIES})

# Emscripten bağlantı seçenekleri
target_link_options(MyWasmModule
  PUBLIC
    "SHELL:-s WASM=1"                       # WebAssembly olarak derle
    "SHELL:-s MODULARIZE=1"                 # Modülerleştirme
    "SHELL:-s EXPORT_NAME='createWasmModule'"  # Modül adı
    "SHELL:-s ALLOW_MEMORY_GROWTH=1"        # Bellek büyümesine izin ver
    "SHELL:-sERROR_ON_UNDEFINED_SYMBOLS=0"  # Tanımsız sembollerde hata verme
)

# VTK modüllerini başlat
vtk_module_autoinit(
  TARGETS MyWasmModule
  MODULES ${VTK_LIBRARIES}
)

# HTML dosyasını build dizinine kopyala
add_custom_command(
  TARGET MyWasmModule
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CMAKE_CURRENT_SOURCE_DIR}/index.html"
    $<TARGET_FILE_DIR:MyWasmModule>
)
