@echo off
rem set PROJECT=sdw
rem set PROJECT=teaser1_countries
set PROJECT=teaser2_hivents
rem set PROJECT=teaser3_sidebar

call "C:\Program Files\nodejs\nodevars.bat"

IF not exist build ( mkdir build )

set cFiles=
for /R script\ %%a in (*.coffee) do call set cFiles=%%cFiles%% %%a

call coffee -c -o build %cFiles%

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
        --cssFormat "less" config/%PROJECT%/style.rose && ^
uglifyjs %jFiles% -o script\histoglobe.min.js && ^
lessc --no-color -x config\%PROJECT%\main.less style\histoglobe.min.css && ^
call utils\replace_line.bat config.php 1 "<?php $config_path = '%PROJECT%'; ?>"
