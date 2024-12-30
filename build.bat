@echo off
::delete build folder
rmdir /s /q build

:: Profil dosyasının adını belirleyin
set PROFILE_NAME=emscripten_profile

:: Profilin mevcut olup olmadığını kontrol edin
echo == Profil kontrolu ==
conan profile list > profiles_list.txt
findstr /R /C:"^%PROFILE_NAME%$" profiles_list.txt >nul 2>&1
if %errorlevel% neq 0 (
    echo [BILGI] Profil bulunamadi, olusturuluyor...
    (
        echo [settings]
        echo os=Emscripten
        echo arch=wasm
        echo compiler=clang
        echo compiler.version=15
        echo compiler.libcxx=libc++
        echo build_type=Release
        echo [tool_requires]
        echo emsdk/3.1.72
        echo ninja/1.12.1
        echo cmake/3.31.0
    ) > %USERPROFILE%\.conan2\profiles\%PROFILE_NAME%
    echo [BILGI] Profil basariyla olusturuldu: %PROFILE_NAME%
) else (
    echo [BILGI] Profil bulundu: %PROFILE_NAME%
)

:: profiles_list.txt dosyasını sil
del profiles_list.txt

:: Conan bağımlılıklarını yükle
echo == Conan bagimliliklerini yukle ==
conan install . --profile=%PROFILE_NAME% --build=missing
if %errorlevel% neq 0 (
    echo [HATA] Conan install isleminde bir sorun olustu!
    exit /b %errorlevel%
)

:: Build işlemi
echo == Conan ile projeyi derle ==
conan build .
if %errorlevel% neq 0 (
    echo [HATA] Conan build isleminde bir sorun olustu!
    exit /b %errorlevel%
)

:: Python HTTP sunucusunu başlat
echo == Python HTTP sunucusu baslat ==
cd build
python -m http.server
if %errorlevel% neq 0 (
    echo [HATA] Python HTTP sunucusu baslatilirken bir sorun olutu!
    exit /b %errorlevel%
)

echo [BAŞARI] Proje basariyla calistirildi!
