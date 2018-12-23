@echo off
REM Use with GMT 5.1.2
setlocal EnableDelayedExpansion

echo " _________  ______  _____      _____    ____   __     ____    "
echo "|  _   _  .' ____ \|_   _|    / ___ `..'    './  |  .' __ '.  "
echo "|_/ | | \_| (___ \_| | |_____|_/___) |  .--.  `| |  | (__) |  "
echo "    | |    _.____`.  | |______.'____.| |    | || |  .`____'.  "
echo "   _| |_  | \____) |_| |_    / /_____|  `--'  _| |_| (____) | "
echo "  |_____|  \______.|_____|   |_______|'.____.|_____`.______.' "
                                                              

echo Sistem Pelayanan Jasa dan Informasi Data Petir
echo Stasiun Geofisika Tuntungan [Version 1.0]
echo Copyright (c) 2017 Stasiun Geofisika Tuntungan
pause
set mainfolder=D:\Ngajar\Konsultasi\Kantor\pelayanan

set F=%mainfolder%\peta.ps
set tanggal=%1
REM set /p tanggal="Tanggal kejadian (1-31)                      : "
set tanggal=00%tanggal%
set tanggal=%tanggal:~-2%
REM set /p bulan="Bulan kejadian (1-12)                        : "
set bulan=%2
set bulan=00%bulan%
set bulan=%bulan:~-2%
REM set /p tahun="Tahun kejadian                               : "
set tahun=%3
REM set /p lon="Koordinat bujur site (min=97.69, max=100.06) : "
set lon=%4
REM set /p lat="Koordinat lintang site (min=0.02, max=4.68)  : "
set lat=%5
REM set /p site="Nama site                                    : "
set site=%6
REM set /p jarak="Jarak yang diinginkan dalam Km (max=100 Km)  : "
set jarak=%7

set ttahun=%date:~-10,4%
set obulan=%date:~-5,2%
set dday=%date:~-2,2%
set waktu=%time%

gmtset FONT Bookman-Demi
gmtset MAP_ANNOT_OBLIQUE=32
gmtset MAP_FRAME_TYPE=plain
gmtset FONT_TITLE=10p
gmtset FONT_ANNOT_PRIMARY=9p
gmtset FONT_LABEL=10p
gmtset MAP_LABEL_OFFSET=0.05i
gmtset MAP_TITLE_OFFSET=0.05i
gmtset FORMAT_GEO_MAP=ddd:mm:ssF
gmtset MAP_GRID_PEN_PRIMARY=0.3p

REM Set nama bulan
if "%bulan%"=="01" set namabulan=JANUARI
if "%bulan%"=="02" set namabulan=FEBRUARI
if "%bulan%"=="03" set namabulan=MARET
if "%bulan%"=="04" set namabulan=APRIL
if "%bulan%"=="05" set namabulan=MEI
if "%bulan%"=="06" set namabulan=JUNI
if "%bulan%"=="07" set namabulan=JULI
if "%bulan%"=="08" set namabulan=AGUSTUS
if "%bulan%"=="09" set namabulan=SEPTEMBER
if "%bulan%"=="10" set namabulan=OKTOBER
if "%bulan%"=="11" set namabulan=NOVEMBER
if "%bulan%"=="12" set namabulan=DESEMBER

set file1=D:\AKUISISI_DATA_PETIR\KML\%tahun%%bulan%%tanggal%.kml
set file2=D:\AKUISISI_DATA_PETIR\ARCHIVE\KML\%tahun%\!namabulan!\%tahun%%bulan%%tanggal%.kml 

REM Set batas peta
for /f "delims=*" %%a in ('cscript //nologo %mainfolder%\data\eval.vbs "%lon%-%jarak%/111.32"') do set eastlon=%%a
for /f "delims=*" %%a in ('cscript //nologo %mainfolder%\data\eval.vbs "%lon%+%jarak%/111.32"') do set westlon=%%a
for /f "delims=*" %%a in ('cscript //nologo %mainfolder%\data\eval.vbs "%lat%-%jarak%/111.32*0.82"') do set southlat=%%a
for /f "delims=*" %%a in ('cscript //nologo %mainfolder%\data\eval.vbs "%lat%+%jarak%/111.32*0.82"') do set northlat=%%a
for /f "delims=*" %%a in ('cscript //nologo %mainfolder%\data\eval.vbs "(%westlon%-%eastlon%)/4"') do set interval=%%a

set judul=PETA SAMBARAN PETIR TANGGAL %tanggal% %namabulan% %tahun%
set R=%eastlon%/%westlon%/%southlat%/%northlat%
set /a jarakskala=%jarak%/2

REM Cek ketersediaan file
if exist %file1% (
    set datakml=%file1%
)
if exist %file2% (
    set datakml=%file2%
)
if not exist %file1% (
    if not exist %file2% (
		goto close
	)
)

REM Menentukan resolusi peta background
if %jarak% GEQ 0 (
    if %jarak% LEQ 20 (
        set dataosmred=%mainfolder%\data\sumut_full_red.tif
		set dataosmgreen=%mainfolder%\data\sumut_full_green.tif
		set dataosmblue=%mainfolder%\data\sumut_full_blue.tif
    )
)
if %jarak% GTR 20 (
    if %jarak% LEQ 60 (
        set dataosmred=%mainfolder%\data\sumut_high_red.tif
		set dataosmgreen=%mainfolder%\data\sumut_high_green.tif
		set dataosmblue=%mainfolder%\data\sumut_high_blue.tif
    )
)
if %jarak% GTR 60 (
    if %jarak% LEQ 90 (
        set dataosmred=%mainfolder%\data\sumut_intermediate_red.tif
		set dataosmgreen=%mainfolder%\data\sumut_intermediate_green.tif
		set dataosmblue=%mainfolder%\data\sumut_intermediate_blue.tif
    )
)
if %jarak% GTR 90 (
        set dataosmred=%mainfolder%\data\sumut_low_red.tif
		set dataosmgreen=%mainfolder%\data\sumut_low_green.tif
		set dataosmblue=%mainfolder%\data\sumut_low_blue.tif
)

REM Kotak pada inset
echo %eastlon% %southlat% > %mainfolder%\kotak
echo %eastlon% %northlat% >> %mainfolder%\kotak
echo %westlon% %northlat% >> %mainfolder%\kotak
echo %westlon% %southlat% >> %mainfolder%\kotak
echo %eastlon% %southlat% >> %mainfolder%\kotak

REM Kotak Frame
echo 0 0 > %mainfolder%\kotakframe
echo 14.5 0 >> %mainfolder%\kotakframe
echo 14.5 10 >> %mainfolder%\kotakframe
echo 0 10 >> %mainfolder%\kotakframe
echo 0 0 >> %mainfolder%\kotakframe

REM Kotak mata angin
echo 0 0 > %mainfolder%\kotakangin
echo 3.1 0 >> %mainfolder%\kotakangin
echo 3.1 1.6 >> %mainfolder%\kotakangin
echo 0 1.6 >> %mainfolder%\kotakangin
echo 0 0 >> %mainfolder%\kotakangin

REM Kotak Legenda
echo 0 0 > %mainfolder%\kotaklegenda
echo 3.1 0 >> %mainfolder%\kotaklegenda
echo 3.1 1.4 >> %mainfolder%\kotaklegenda
echo 0 1.4 >> %mainfolder%\kotaklegenda
echo 0 0 >> %mainfolder%\kotaklegenda

REM Kotak judul
echo 0 0 > %mainfolder%\kotakjudul
echo 13.4 0 >> %mainfolder%\kotakjudul
echo 13.4 0.7 >> %mainfolder%\kotakjudul
echo 0 0.7 >> %mainfolder%\kotakjudul
echo 0 0 >> %mainfolder%\kotakjudul

REM Kotak dibuat oleh
echo 0 0 > %mainfolder%\kotakoleh
echo 3.1 0 >> %mainfolder%\kotakoleh
echo 3.1 1.2 >> %mainfolder%\kotakoleh
echo 0 1.2 >> %mainfolder%\kotakoleh
echo 0 0 >> %mainfolder%\kotakoleh

REM Legenda sebaran petir
echo H 12 1 Legenda  > %mainfolder%\legendasebaran
echo S 0.1i a 0i yellow 0.5p 0i >> %mainfolder%\legendasebaran
echo S 0.1i a 0.2i yellow 0.5p 0.3i Lokasi Site >> %mainfolder%\legendasebaran
echo S 0.1i a 0i yellow 0.5p 0i  >> %mainfolder%\legendasebaran
echo S 0.1i kflash 0.2i red 0.5p 0.3i Sambaran Petir >> %mainfolder%\legendasebaran

REM PETA UTAMA
psxy %mainfolder%\kotakframe -Jx2 -R0/20/0/20 -W1.5 -K -X0.4 -Y0.4 > %F%
psbasemap -R%R% -JM20 -K -B%interval%wsne -X1 -Y1 -O --MAP_FRAME_PEN=3.5p >> %F%
pscoast -R -JM -O -K -N1 -Lfx23.7/14.1/1/%jarakskala%k+jb+lkm -Tx23.7/15.1/0.5i >> %F%
grdimage !dataosmred! !dataosmgreen! !dataosmblue! -JM -R -K -O -Ba%interval%g%interval%WSne >> %F%
kml2gmt !datakml! -Fs > %mainfolder%\petir.dat
psxy -R -JM -O -K %mainfolder%\petir.dat -Skflash/0.5 -W0.1 -Gred  >> %F%
echo %lon% %lat% | psxy -R -JM -O -K -Sa0.5 -W1 -Gyellow  >> %F%
echo %lon% %lat% %site% | pstext -R -JM -O -K -D0.5 -F+f10 >> %F%

REM Judul peta
psxy %mainfolder%\kotakjudul -Jx2 -R0/20/0/20 -O -K -W1.5 -Gblue -Y17 >> %F%
echo 13.6 0.7 %judul% | pstext -R -JM -O -K -N -F+f18,white+jCM >> %F%

REM Legenda peta
psxy %mainfolder%\kotakangin -Jx2 -R0/20/0/20 -O -W1.5 -K -X20.6 -Y-3.85 >> %F%
psxy %mainfolder%\kotaklegenda -Jx2 -R0/20/0/20 -O -W1.5 -K -Y-3.2 >> %F%
pslegend -Dx0.95i/1.2i/1.4i/0.3i/TC -Jx2 -K -R -O -Y-0.4 %mainfolder%\legendasebaran >> %F%

REM Inset peta
psbasemap -R96.8/101.0/0/4.7 -JM6.1 -K -B2wsne -X0.05 -Y-6.8 -O --MAP_FRAME_PEN=3.5p >> %F%
grdimage %mainfolder%\data\sumut_crude.tif -JM -R -K -D -O >> %F%
psxy -R -JM -O -K kotak -W2,red >> %F%

psxy %mainfolder%\kotakoleh -Jx2 -R0/20/0/20 -O -W1.5 -K -X-0.05 -Y-2.75>> %F%
echo 1.6 0.5 Dibuat oleh : > %mainfolder%\teks
echo 1.6 0.35 Stasiun Geofisika Tuntungan >> %mainfolder%\teks
echo 1.6 0.2 BMKG >> %mainfolder%\teks
pstext -R -Jx -O -K %mainfolder%\teks -F+f8 >> %F%
echo 0 -0.3 Generated at %dday%-%obulan%-%ttahun% %waktu% WIB | pstext -R -Jx -O -K -N -F+jML >> %F%
psimage %mainfolder%\data\bmkg.ras -R -Jx -O -W0.8 -X2.77 -Y1.35 >> %F%

REM Simpan menjadi PNG
ps2raster %F% -A -Tg -P -Fpeta -E300
copy peta.png %mainfolder%\

REM Hapus file sisa
:close
del gmt.conf gmt.history %mainfolder%\kotak %mainfolder%\kotakangin %mainfolder%\kotakframe %mainfolder%\kotakjudul %mainfolder%\kotaklegenda %mainfolder%\kotakoleh %mainfolder%\legendasebaran %mainfolder%\teks %mainfolder%\petir.dat %mainfolder%\*.bb %F%
