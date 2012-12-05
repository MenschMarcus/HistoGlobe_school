function HistoMap(timeline) {
    //"use strict";
    // =========================== H E A D E R =========================== //
    var hmap = {};
    var tline = timeline;
    var po = org.polymaps;
    var layers = [];
    var borderevent = {}; // map of eventid => [borderid, ..] used for coloring borders
    var selectedevent = null; // keep track of which event has been selected
    
    hmap.tline = timeline;
    hmap.po = po;
    hmap.layers = layers;
    hmap.setEventId = setEventId;
    hmap.gotopoint = gotopoint;
    
    // =================== I M P L E M E N T A T I O N =================== //    
    
    // PolyMaps map object
    var map = po.map().container(document.getElementById("map").appendChild(po.svg("svg")))
        .center({
        lat: 60,
        lon: 10
        })
        .zoomRange([2, 7])
        .zoom(4)
        .add(po.dblclick())
        .add(po.drag())
        .add(po.wheel().smooth(false))
        .centerRange([
            {lat:-80, lon:-Infinity},
            {lat:+80, lon:+Infinity}]);
    hmap.map = map;     // public for debugging purposes
    
    // give map extent to timeline on every move, but not while plain zooming is in progress
    map.on('move', function(m) {
        if (!m.params.zoompan) hmap.tline.setMapExtent(map.extent());
    });
    
    // give initial extent
    hmap.tline.setMapExtent(map.extent());
        
    // ======== Setup layers ========= //
    
    // map controls        
    var controls = po.compass().pan("small").zoom("big");
    map.add(controls);
    map.add(po.touch()); // needs testing on touch phone
    map.add(po.arrow());

/*  // old geographical layer, leave here as a backup
    var geo = po.image()
        .url("http://s3.amazonaws.com/com.modestmaps.bluemarble/{Z}-r{Y}-c{X}.jpg")
        .visible(true);      
    addPMLayer(geo);
    map.container().setAttribute("class", "YlOrRd");
*/

    // New rendering, jpeg format, levels 0-7
    var geo = po.image().url(function (a) {
        var tilenum = Math.pow(2, a.zoom);
        var r = tilenum - 1 - a.row;
        var c = a.column % tilenum;
        c = c < 0 ? c + tilenum : c;
        return "http://kbaa.chotoro.fi/histo/r1j/" + a.zoom + "/" + c + "/" + r + ".jpg";
    }).visible(true);



    addPMLayer(geo);
    map.container().setAttribute("class", "YlOrRd");

    hmap.reload = function() {
      for (var i in layers) {
        layers[i].reload();
      }
    }

    function gotopoint(data) {
        // using center
        map.center({lat:parseFloat(data.lat), lon:parseFloat(data.lon)})
    }
    function addBorderEventID(bid, eid) {
        if (!borderevent[eid]) {
            borderevent[eid] = {};
        }
        borderevent[eid][bid]=1;
    }
    
    // highlight borders/event by event id    
    function setEventId(id) {
        var cl = '', i;
        
        // clear event-selected borders
        var all = $(".border");
        var tmp;
        for (i = 0; i<all.length;i++) {
            tmp = n$(all[i]);
            tmp.attr("class",tmp.attr("class").replace(" evtselect",""));
        }
        
        // clear last event if selected,
        // note, there may be multiple id's, in different layers
        var sel_temp  = $('.evtclicked');
        for (i = 0; i<sel_temp.length; i++) {
            sel_temp[i].setAttribute("class","event");
        }
            
        selectedevent = null;
        
        // if not clearing id
        if (!!id) {
            //bring event(s) forward and set class
            var evt_current = $('#event_' + id);
            for (i = 0; i<evt_current.length; i++) {
                evt_current[i].parentNode.appendChild(evt_current[i]);
                evt_current[i].setAttribute("class","event evtclicked");
            }
            selectedevent = id;
            
            // color borders related to id
            for (i in borderevent[id]) {
                var res = $("#border" + i );
                for (i = 0; i<res.length; i++) {
                    cl = n$(res[i]).attr("class");
                    n$(res[i]).attr("class", cl + " evtselect");
                }
            }
        }
    }
    
    
    
    // Borders layerpile
    hmap.borderLA = (function () {
        var b = LayerArray(map, 'border');
        var now    = '';  // current date, updated by callback from timeline
        var canon  = 'z'; // lower bound (canonical date), initial value larger than any date string
        var ubound = '!'; // upper bound for this canonical date, initial value less than any date string
        var req;                   // ajax request reference
        
        // set timeline callback
        b.nowChanged = function (nowdate) {
            var newnow  = nowdate.getFullYear() + '-' +
                padzero((nowdate.getMonth()+1)) + '-' +
                padzero(nowdate.getDate());
                
            if (newnow != now) {
                // if we're between the old now and its canonical date
                // there's no need to update
                if (canon < newnow && newnow < ubound ) {
                    now=newnow;
                    return;
                }
                now=newnow;
                // abort any previous calls
                if (req) req.abort();
                
                // find canonical date + range
                req = $.ajax({
                 type: 'GET',
                 async:true,
                 url: "api/iscanonical.php?now=" + newnow,
                 success:
                    function (data) {
                        data = data.split(';');
                        
                        // if canonicaldate is different, we need to reload
                        if (canon != data[0]) {
                            canon = data[0];
                            ubound = data[1];
                            if (now) b.reload(now);
                            // reload country names as well
                            hmap.countrynameLA.nowChanged(nowdate);
                        }
                        req = null;
                    },
                 dataType:"text"
                });
            }
        };

        b.init(
            function (a) {
                return "api/tilegenerator.php?layer=borders&now=" + now + "&zoom=" + a.zoom;
            },
            loadborder,showborder,3
        );
        
        tline.addListener(b);
        return b;
    }());
    
    
    
    //Countrynames
    hmap.countrynameLA = (function () {
        var cn = LayerArray(map,"countryname");
        var now = ''; //updated by callback from timeline
        // timeline callback
        cn.nowChanged = function (date) {
            var tmp  = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate();
            if (tmp != now) {
                now=tmp;
                if (now) cn.reload(now);
            }
            
        };
        // Instead of adding as timeline listener, we rely on border layer for updates
        // using its logic for canonical dates etc.
        cn.init(
            function (a) {
                return "api/countrynames.php?&now=" + now + "&zoom=" + a.zoom;
            },
            loadcountryname,showcountryname,2
        );        
        return cn;
    }());
    //Countrynames done


    // Country polygon layer, content set by static features
    hmap.polyController = (function () {
        var ctr = {},
            aucache = [];
            polycache = [];
            
        ctr.layer = po.geoJson()
            .visible(true)
            .features([]) // initial empty set of features
            .tile(false)
            .id("poly_layer0")
            .on("load", loadpoly)
            .on("show", showpoly);
        
        addPMLayer(ctr.layer);
        
        // Create country/adminUnit multipolygon feature array
        // e: array of (border) features
        // au: adminUnit array
        ctr.setPoly = function(e, au) {
            setTimeout(function (){setPoly(e,au)},0);
        }
        
        function setPoly(e, au) {
            if (!e || e.length ==0) return;
            if (au) for(var i=0;i<au.length; i++) {
                aucache[au[i].adminID]  = au[i];
            }
            e = e.slice(); // copy features
            
            // sort borders into buckets by adminunit 1 and 2
            var countries = [];
            for (var i=0; i<e.length; i++) {
                e[i] = e[i].data; // we're not interested in the element, just the GeoJSON
                var eprops = e[i].properties;
                
                var tmp = e[i];
                if (eprops.au1 == "18") continue; // TODO HACK! fix later how borders are selected for polygons
                if (!countries[eprops.au1]) {
                    countries[eprops.au1] = [];
                    countries[eprops.au1].hasL1 = false;
                }
                if (eprops.level == "1")
                    countries[eprops.au1].hasL1 = true;

                countries[eprops.au1].push(e[i]);
                if (eprops.au2 && eprops.au2 != "-1") { // exclude dummy adminIDs (-1)
                    if (!countries[eprops.au2])
                        countries[eprops.au2] = [];
                    countries[eprops.au2].push(e[i]);
                }
            }
            
            // create multipolygon for each country
            var cpolygons = [];
            
            function makePolyFeature(c, p) {
                return {
                    geometry: {
                        coordinates: c,
                        type: "MultiPolygon"
                    },
                    properties: p,
                    type: "Feature"
                }
            }
            
            for (var c in countries) {
                var parts = [];  // partial polygons
                var cpoly = [];  // finished polygons
                
                
                
                // default poperties
                if (aucache[c]) {
                    props = aucache[c];
                }
                for (var feat = 0; feat < countries[c].length; feat++) {
                    var feature = countries[c][feat];
                    // skip l2 borders if this unit has some l1 borders
                    if (countries[c].hasL1 && feature.properties.level != "1"){
                        continue;
                    }

                    // go through each path
                    for (var g = 0; g < feature.geometry.coordinates.length; g++) {
                        var mthing = feature.geometry.coordinates[g];
                        if (mthing[0]['0'] != mthing[mthing.length - 1]['0'] ||
                            mthing[0]['1'] != mthing[mthing.length - 1]['1'])
                        {   // end coordinates are not the same, do later
                            parts.push(mthing);
                        } else {
                            // this is a complete polygon
                            cpoly.push([mthing]);
                        }
                    }
                }
                function coordmatch(a,b) {
                    if (a['0'] == b['0'] && a['1'] == b['1']) {
                        return true;
                    }
                    return false;
                }
                
                // now connect remaining paths together
                while (parts.length > 1) {
                    var first = parts[0];
                    // search for matching part
                    var found = false;
                    for (var f = 1; f < parts.length; f++) {
                        
                        // end and beginning match
                        if (coordmatch(first[first.length-1], parts[f][0])) {
                            parts[0] = first.concat(parts[f]);
                            first = parts[0];
                            parts.splice(f,1);
                            f--;
                            found = true;
                        } else if (coordmatch(first[first.length-1], parts[f][parts[f].length-1])) {
                        // end and end match
                            parts[f].reverse();
                            parts[0] = first.concat(parts[f]);
                            first = parts[0];
                            parts.splice(f,1);
                            f--;
                            found = true;
                        } else if (coordmatch(first[0], parts[f][parts[f].length-1])) {
                        // beginning and end match
                            parts[0] = parts[f].concat(first);
                            first = parts[0];
                            parts.splice(f,1);
                            f--;
                            found = true;
                        } else if (coordmatch(first[0], parts[f][0])) {
                        // beginning and beginning match
                            parts[f].reverse();
                            parts[0] = parts[f].concat(first);
                            first = parts[0];
                            parts.splice(f,1);
                            f--;
                            found = true;
                        }
                        
                        if (coordmatch(first[0], first[first.length-1])) {
                            // made a polygon
                            cpoly.push([first]);
                            parts.splice(0,1);
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                    // can't find a match for this part, just wing it
                    // and push it in as a polygon anyway
                        if (!coordmatch(parts[0][0], parts[0][parts[0].length-1]))
                            parts[0].push(parts[0][0]);
                        cpoly.push([parts[0]]);
                        parts.splice(0,1);                    
                    }
                }
                // add any remaining path as polygon
                if (parts.length==1) {
                    // connect ring if necessary
                    if (!coordmatch(parts[0][0], parts[0][parts[0].length-1]))
                        parts[0].push(parts[0][0]);
                    cpoly.push([parts[0]]);
                }
                cpolygons.push(makePolyFeature(cpoly, props));
            }
            ctr.layer.features(cpolygons);
        };
        return ctr;
    }());
    
    //Events
    hmap.eventLA = (function () {
        var e = LayerArray(map,"event");
        var t1 = '';
        var t2 = ''; //updated by callback from timeline
        var cats;
        var callTimeline = false;
        
        // make key for polymaps cache
        function getKey() {
            if (!cats) return t1 + "-" + t2 + "_" +"---"; 
            else return t1 + "-" + t2 + "_" + (cats.social?"s":"-") + (cats.domestic?"d":"-") + (cats.foreign?"f":"-");
        }
        
        // timeline callbacks
        e.periodChanged = function (d1, d2) {
            callTimeline = true;
            var temp1 = d1.getFullYear();
            var temp2 = d2.getFullYear();
            if (t1 != temp1 || t2 != temp2) {
                t1=temp1;
                t2=temp2;
                if (cats && t1 && t2) e.reload(getKey());
            }
        };
        e.categoryChanged = function (c) {
            cats = c;
            callTimeline = true;
            if (cats && t1 && t2) e.reload(getKey());
        }
        e.onLayerLoad(function (e) {
          if (callTimeline) main.timeline.setHistEvents(e.features);
        });
        
        e.init(
            function (a) {
                return "api/tilegenerator.php?layer=events&start=" + t1 +
                       "&end=" + t2 +
                       "&zoom=" + a.zoom + (cats?cats.asUrlParam():'');
            },
            loadevent,showevent,4
        );
        
        tline.addListener(e);
        
        return e;
    }());
    //Events done 
    
    /**
     * Generic LayerArray
     * Handles a pile of arbitrary number of layers, flips layer only 
     * after layer fully reloads.
     * (possibly caching in the future?)
     */
    function LayerArray(map, name) {
        var LA = {}, // returned
            layers = [],
            visible = 0,
            size = 0,    //
            zoom,
            urlfn,
            doflip = false,
            onlayerreload,
            onlayerload;
        
        //public vars
        LA.polayers = layers;
        
        // layer functions
        LA.flipToNext = flipToNext;
        LA.reload = reload;
        LA.init = init;
        LA.setzoom = setzoom;
        LA.setDkey = setDkey;
        
        // timeline callbacks
        LA.nowChanged = function () {};     //do nothing by default
        LA.periodChanged = function () {};  //..
        LA.categoryChanged = function () {};//..

        
        LA.onLayerReload = function(f) {
            onlayerreload = f;
        }
        
        LA.onLayerLoad = function(f) {
            onlayerload = f;
        }
        
        // Fader controller, set layers to fade in or out
        var fader = new function() {
            var f = {},
                time    = 50,   // animation delay
                step    = 0.36, // fading step
                target  = [],   // target opacity
                opacity = [],   // current opacity
                conts   = [];   // layer containers
            var fn;
            
            // showing or hiding layer registers it for fading purposes
            f.hide = function(i) {
                if(!conts[i]) conts[i] = layers[i].container();
                layers[i].visible(false);
                target[i]=0;
                opacity[i]=0;
                conts[i].setAttribute("style","opacity:" + target[i]);
            };
            
            f.show = function(i) {
                if(!conts[i]) conts[i] = layers[i].container();
                layers[i].visible(true);
                target[i]=1;
                opacity[i]=1;
                conts[i].setAttribute("style","opacity:" + target[i]);
            };
            
            var interval = setInterval(
            fn = function() {
                var stufftodo = false;
                for (var i=0; i<conts.length; i++) {
                    var current = opacity[i];
                    if (current != target[i]) {
                        if (target[i] > 0 && !layers[i].visible()) {
                            layers[i].visible(true);
                        }
                        var set;
                        if (target[i] < current) {
                            set = Math.max(0,current - step);
                        } else {
                            set = Math.min(1,current + step);
                        }
                    
                        conts[i].setAttribute("style","opacity:" + Math.pow(set,0.53));
                        opacity[i] = set;
                        if (set == 0) {
                            layers[i].visible(false);
                        }
                        stufftodo = true;
                    }
                }
                if (!stufftodo) {
                    clearInterval(interval);
                    interval = null;
                }
            }, time);
            
            f.stopFading = function() {
                clearInterval(interval);
            }
            f.startFading = function() {
                if (!interval) interval = setInterval(fn, time);
            }
            f.fadeout = function (i) {
                target[i] = 0;
                f.startFading();
            };
            f.fadein = function (i) {
                target[i] = 1;
                f.startFading();
            };
            return f;
        }();


        function setzoom(z) {
            zoom=z;
        }
        
        // set cache key in all layers
        // should be called when layer changes semantically
        function setDkey(dkey) {
            for (var i in layers) {
                layers[i].cache.setDkey(dkey);
            }
        }
        
        // flip to next layer in pile
        function flipToNext() {
            if (!doflip) return;
            doflip=false;
            if (size === 0) { return; }
            flip((visible + 1) % size);
        }

        // flip to arbitrary layer i
        function flip(i) {
            fader.fadein(i);
            fader.fadeout(visible);
            visible = i;
            if (onlayerreload) onlayerreload(layers[i]);
        }

        // layer URL was (possibly) updated, reload next buffer
        // buffer will be flipped when onload trigger finishes
        function reload(key) {
            if (size === 0) { return; }
            var nextidx = (visible + 1) % size;
            doflip = true;                     // allow flip after reload
            layers[nextidx].cache.setDkey(key);
            layers[nextidx].visible(true);     // set to visible which reloads
            layers[nextidx].reload();
        }
        
        // synchronise cache from layer source to the others
        function syncCaches(source) {
               var sourcecache = layers[source].cache;
            for (var i in layers) {
                if (i != source) {
                    layers[i].cache.syncFrom(sourcecache);
                }
            }
        }

        // set layer "buffers"
        // urlfunction : function that returns url
        // loadfunction : called onload
        // showfunction : called onshow
        // asize : number of layers in pile, minimum 1
        function init(urlfunction, loadfunction,showfunction, asize) {
            size = asize;
            if (!size || size < 1) size = 1;
            
            for (var i = 0; i < size; i += 1) {
                var layer = po.geoJson()
                    .url(urlfunction)
                    .visible(false)
                    .tile(false)
                    .zoom(function(zval){ return zoom?zoom:zval})
                    .id(name + "_layer" + i)
                    .on("load", function (elements) {
                        loadfunction(elements);
                        // only callback if we're not flipping layers
                        if (doflip) LA.flipToNext();
                        if (onlayerload) onlayerload(elements);
                    })
                    .on("show",function(elements) {
                        showfunction(elements);
                        //if (doflip) LA.flipToNext(); // unsure if needed here, breaks fading
                        //if (onlayerload) onlayerload(elements);
                    });
                
                layers.push(layer);
                layer.container().setAttribute('class','svgLayer_' + name);
                // hide layer
                fader.hide(i);
                addPMLayer(layer);
            }
            // set the first layer to visible
            //fader.show(0);
        }

        return LA;
    } // end LA

    // =========== Utility funcs ===========
    
    // pad zero in front of 1-char strings 
    function padzero(str) {
        return (''+str).length==1? '0'+str : str;
    }
    
    // add a PolyMaps layer, making sure the controls remain on top.
    // z-order in svg depends on element order
    function addPMLayer(layer) {
        map.remove(controls);
        map.add(layer).add(controls);
        return this;
    }

    // ====== Layer loader functions ======
    function showevent(e) {
        eventCommon(e);
    }
    function eventCommon(e) {
      for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                props = feature.data.properties;

            var elem = n$(feature.element);
            var sel_class = "";
            if (selectedevent == props.histEventID) {
                elem.attr("class", "event evtclicked");
                feature.element.parentNode.appendChild(feature.element);
            } else {
                elem.attr("class", "event");
            }
            // change radius based on zoom
            
        }
    }
    function loadevent(e) {
        var i;
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                props = feature.data.properties,
                n = props.name,
                t = props.date,
                z = props.zoom;
            var elem = n$(feature.element);
            
            elem.add("svg:title").text(n + " (" + t + ")");
            
            var radius =  parseFloat(elem.attr("r"));
            elem.attr("r", radius * (z/3) );
            
            feature.element.onclick = function(p) {
                return function(clickevt){main.getEventInfo(p, clickevt)};
            }(props)
            
            elem.attr("id", 'event_' + props.histEventID );
        }
        eventCommon(e);
    }
    
    function showborder(e) {
        if (e && hmap.polyController) hmap.polyController.setPoly(e.features, e.adminUnits);
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                elem    = n$(feature.element),
                props   = feature.data.properties;

            // check if this border is selected through event
            var sel_class = "";
            if (selectedevent && 
                borderevent[selectedevent] && 
                borderevent[selectedevent][props.auBorderID]) {
                sel_class = " evtselect";
            }
            
            var borderlevel = "lvl" + props.level;
            if (!props.au2) borderlevel += " ";
            elem.attr("class", "border " + borderlevel + sel_class);

        }
    }

    function loadborder(e) {
        var i;
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                elem    = n$(feature.element),
                props   = feature.data.properties;
            
            // store eventid for this border
            if (props.histEventID != "")
                addBorderEventID(props.auBorderID, props.histEventID);
            
            elem.attr("id", "border" + props.auBorderID);
        }
        showborder(e);
    }
    function showpoly(e) {
    }
    function loadpoly(e) {
        var i;
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                elem    = n$(feature.element),
                props   = feature.data.properties;
            
            // set tooltip
            var n = props.nameOfficial;
            elem.add("svg:title").text(n);
            elem.attr("id", "poly" + props.id);
            elem.attr("class", "poly");
            
            feature.element.onclick = (function (pr) {
              return function(){main.setCountryInfo(pr);}
            }(props));
        }
        showpoly(e);
    }
    var ffmatch = /Firefox\/(\d+)\./i.exec(navigator.userAgent);
    var chrome = /chrome/i.exec(navigator.userAgent);
    var windows = /windows/i.exec(navigator.userAgent);
    var opera = /opera/i.exec(navigator.userAgent);
    function showcountryname(e) {
        var zoom = map.zoom();

        var zsmooth = (zoom - Math.floor(zoom))/6 * 0;        
        var fsize = (1.30 * zoom/4 - zsmooth);
        
        var zset = Math.max(2,Math.min(7, Math.floor(zoom)));

        
        // extra style attributes
        var extra = '';
        if (true || !opera) {
          extra = 'filter:url(#dropshadow_cname);';
        }
        
        
        for (var i = 0; i < e.features.length; i += 1) {
            var elem = n$(e.features[i].element);

            elem.attr('style',extra);
            // set classes
            // to reduce size jump between zoom levels, one class per zoom (or thereabout)
            elem.attr("font-size", fsize * (e.features[i].data.properties.level > 1? 0.8:1) + "em");
            elem.attr("class", "countryname czoom" + zset);
            
            // switch between one name or both
            if (Math.floor(zoom) <= 4) {
                elem.child(0).attr('style',extra + 'opacity:1;');
                elem.child(1).attr('style','display:none');
                elem.child(2).attr('style','display:none');
            } else {
                elem.child(0).attr('style','opacity:0;');
                elem.child(1).attr('style',extra + '');
                elem.child(2).attr('style',extra + '');
            }
        }
    }
    function loadcountryname(e) {
        var i,
            zoom = Math.ceil(map.zoom());
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                props = feature.data.properties;
                noff = props.nameOfficial,
                ncom = props.nameCommon,
                elem = n$(feature.element);
            
            elem.attr("id","cname_" + props.adminID);
            // test splitting long names, disabled
            elem.attr("name", noff);
            //feature.element.setAttribute("style","filter:url(#dropshadow);");
            // add both common name and official name
            elem.add("svg:tspan").attr('y',0).attr('x',0).text(ncom);
            elem.add("svg:tspan").attr('y',0).attr('x',0).attr('class','nameOfficial').text(noff);
            elem.add("svg:tspan").attr("y", Math.ceil(zoom)*7 - 7).attr("x",0).text('('+ncom+')').attr('class','subname'); // (noff.length-ncom.length) * textwidth
        }
        showcountryname(e);
    }

    function loadstatic(e) {
        var i;
        for (i = 0; i < e.features.length; i += 1) {
            var feature = e.features[i],
                n = feature.data.properties.name;
            n$(feature.element).add("svg:title").text(n);
            if (feature.data.properties.active === "true") {
                n$(feature.element).attr("class", "active country");

            } else {
                n$(feature.element).attr("class", "country");
            }
        }
    }
    
    return hmap;
}

