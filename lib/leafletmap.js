            var sliderControl = null;

            // PETA UTAMA
            //var map = new L.Map('my-map', { zoomControl:false });
            var osmUrl='https://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}';
			//var osmUrl='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
            var osmAttrib='Lightning Data by Stasiun Geofisika Tuntungan <a href="http://bmkg.go.id">BMKG</a>';
            var osm = new L.TileLayer(osmUrl, {minZoom: 5, maxZoom: 18, attribution: osmAttrib});

            // LOKASI TOWER
            var towerIcon = L.icon({
                iconUrl: 'img/tower.svg',
                iconSize:     [38, 95], // size of the icon
            });

            //remember last position
            var rememberLat = document.getElementById('latitude').value;
            var rememberLong = document.getElementById('longitude').value;
            if( !rememberLat || !rememberLong ) { rememberLat = 3.5012; rememberLong = 98.5625;}
            var map = new L.Map('my-map', {
                'center': [rememberLat, rememberLong],
                'zoom': 11,
                'layers': [osm],
                'zoomControl': false
            });
            var marker = L.marker([rememberLat, rememberLong], {icon: towerIcon}, {
                draggable: false
            }).addTo(map);

            function updateLatLng(lat,lng,reverse) {
                if(reverse) {
                    marker.setLatLng([lat,lng]);
                    map.panTo([lat,lng]);
                } else {
                    document.getElementById('latitude').value = marker.getLatLng().lat;
                    document.getElementById('longitude').value = marker.getLatLng().lng;
                    map.panTo([lat,lng]);
                }
            }

            //BACA DATA PETIR
            var markersLayer = new L.LayerGroup();
            var sliderControl = L.control.sliderControl();

            function updateData() {
                map.removeLayer(markersLayer);
                markersLayer.clearLayers();

               // map.removeControl(sliderControl);
                tanggal=moment(document.getElementById('tanggal').value).format('YYYYMMDD');
                bujur=document.getElementById('longitude').value;
				lintang=document.getElementById('latitude').value;
                jam_awal=document.getElementById('jam_awal').value;
				jam_akhir=document.getElementById('jam_akhir').value;
                $.ajax({
                    type: 'POST',
                    url: 'script/script.php',                
                    data: ({tanggal:tanggal,
						bujur:bujur,
						lintang:lintang,
						jam_awal:jam_awal,
						jam_akhir:jam_akhir}),
                    success: function(data) {
                    }  
                });

                var delayInMilliseconds = 4000;
                var dt = new Date();
				
                setTimeout(function(){
                    $.getJSON('data/petir.geojson?a='+dt.getTime(), function(data) {
                        
                        var CGP = L.icon({
                            iconSize: [25, 25],
                            iconAnchor: [13, 27],
                            popupAnchor:  [1, -24],
                            iconUrl: 'img/lightning.svg'
                        });
                        var CGN = L.icon({
                            iconSize: [25, 25],
                            iconAnchor: [13, 27],
                            popupAnchor:  [1, -24],
                            iconUrl: 'img/lightning.svg'
                        });
                        var IC = L.icon({
                            iconSize: [25, 25],
                            iconAnchor: [13, 27],
                            popupAnchor:  [1, -24],
                            iconUrl: 'img/lightning.svg'
                        }); 
                    
                        delete geojson;
                        geojson = L.geoJson(data, {
                            pointToLayer: function(feature, latlng) {
                            if (feature.properties.type === 0) {
                                return L.marker(latlng, {icon: CGP});
                            } else {
                                return L.marker(latlng, {icon: CGN});
                                }
                            },
                        });

                        geojson.addTo(markersLayer);
                        
                        markersLayer.addTo(map);

                        //TIME SLIDER
                        var sliderControl = L.control.sliderControl({
                            position: "topright",
                            layer: geojson,
                            range: true
                        });
                        //var keys = Object.keys(markersLayer);
            //                var seen = [];
            //
            //                console.log(JSON.stringify(markersLayer, function(key, val) {
            //                   if (val != null && typeof val == "object") {
            //                        if (seen.indexOf(val) >= 0) {
            //                            return;
            //                        }
            //                        seen.push(val);
            //                    }
            //                    return val;
            //                }));

                        //console.log(sliderControl.options);
                        //Make sure to add the slider to the map ;-)

            //            map.addControl(sliderControl);
                        //An initialize the slider
            //            sliderControl.startSlider();
                        
                        // map.hideControl(sliderControl );
                    });
                }, delayInMilliseconds); 
            };
            
            //GRID KOORDINAT
            var options = {showOriginLabel: true,
                redraw: 'moveend',
                zoomIntervals: [
                    {start: 0, end: 3, interval: 50},
                    {start: 4, end: 6, interval: 5},
                    {start: 7, end: 8, interval: 3},
                    {start: 9, end: 10, interval: 0.5},
                    {start: 11, end: 11, interval: 0.25},
                    {start: 12, end: 12, interval: 0.125},
                    {start: 13, end: 14, interval: 0.05},
                    {start: 15, end: 16, interval: 0.0125},
                    {start: 17, end: 20, interval: 0.005}
                ]};
            L.simpleGraticule(options).addTo(map);

            //SKALA PETA
            L.control.betterscale({maxWidth: 300, metric: true, imperial: false}).addTo(map);

            //LEGENDA
            var legend = L.control({position: 'bottomright'});

            legend.onAdd = function (map) {
                var div = L.DomUtil.create('div', 'info legend');
                div.innerHTML = ('<i style="background:"></i> ' + '<br>'+'<img src="img/logo_bmkg.png" alt="Logo BMKG">' +'<br>'+
                    '<h3>Dibuat oleh :</h3>' + '<h3>Stasiun Geofisika Tuntungan</h3>' + '<h3>BMKG</h3>' );
                return div;
            };

            legend.addTo(map);

            //PETA INSET
            var osm2 = new L.TileLayer(osmUrl, {minZoom: 0, maxZoom: 13, attribution: osmAttrib });
            var miniMap = new L.Control.MiniMap(osm2, { toggleDisplay: false, width: 264, height: 264}).addTo(map);

            //LEGENDA
            var legend2 = L.control({position: 'bottomright'});

            legend2.onAdd = function (map) {
                var div2 = L.DomUtil.create('div', 'info legend');
                div2.innerHTML = ('<i style="background:"></i> ' + '<h3>LEGENDA</h3>' +
                    '<h3> <img src="img/lightning.svg" alt="Sambaran Petir">Sambaran Petir</h3>' +
                    '<h3> <img src="img/tower.svg" alt="Lokasi Site">Lokasi Site</h3>' );
                return div2;
            };
            legend2.addTo(map);

            //TITLE
            var legend5 = L.control({position: 'topleft'});
            var sitechg = false;
            var datechg = false;

            moment.locale('id');
            function updateSite(){
                if (sitechg == true || datechg == true) {
                    legend5.remove(map);
                    sitechg = false;
                    datechg = false;
                }
                nameSite=document.getElementById('site').value.toUpperCase();
                inputTanggal=moment(document.getElementById('tanggal').value).format('DD MMMM YYYY').toUpperCase();

                var legend3 = L.control({position: 'topleft'});
                legend3.onAdd = function (map) {
                    var div3 = L.DomUtil.create('div', 'judul');
                    div3.innerHTML = ('<div class="title">' +'<br>'+ '<p>PETA SAMBARAN PETIR TANGGAL ' + inputTanggal +
                        '</p>'+'<p>DI SEKITAR WILAYAH SITE ' + nameSite + '</p>' +'<br>'+'</div> ' );
                    return div3;
                };
                if (sitechg == false || datechg == false) {
                   legend5 = legend3;
                   sitechg = true;
                   datechg = true
                }
                legend5.addTo(map);
            }
                
            //MATA ANGIN
            var legend4 = L.control({position: 'bottomleft'});

            legend4.onAdd = function (map) {
            var div4 = L.DomUtil.create('div');
                div4.innerHTML = ('<div class="arrow">'+'<img src="img/compass.png" alt="Mata Angin">'+'</div> ' );
                return div4;
            };
            legend4.addTo(map);

            //CETAK PETA
            var printer = L.easyPrint({
                tileLayer: osm,
                exportOnly: true,
                hideControlContainer: false,
                position: 'bottomleft',
                hidden: true
            }).addTo(map);

            function manualPrint () {
                printer.printMap('CurrentSize', 'Peta Petir')
            }
			