@echo off
call "C:\Program Files\nodejs\nodevars.bat"

@echo off
call "data_src\hivents\generate.bat"

@echo off
call "data_src\labels\generate.bat"

@echo off
call "data_src\paths\generate.bat"

IF not exist build ( mkdir build )

@echo off
for /R script\ %%a IN (*.coffee) do call coffee -c -o build %%a

@echo off
set jFiles=
for /R build\ %%a in (*.js) do call set jFiles=%%jFiles%% %%a

rosetta --jsOut "build/default_config.js" ^
        --jsFormat "flat" ^
        --jsTemplate "var HGConfig;(function() {<%%= preamble %%>HGConfig = <%%= blob %%>;})();" ^
        --cssOut "build/default_config.less" ^
        --cssFormat "less" config/common/default.rose && ^
rosetta --jsOut "build/config.js" ^
        --jsFormat "flat" ^
        --jsTemplate "(function() {<%%= preamble %%> $.extend(HGConfig, <%%= blob %%>);})();" ^
        --cssOut "build/config.less" ^
        --cssFormat "less" config/exemplum/style.rose && ^
uglifyjs %jFiles% -o script\histoglobe.min.js && ^
lessc --no-color -x style\histoglobe.less style\histoglobe.min.css
