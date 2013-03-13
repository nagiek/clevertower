/**
 * @license RequireJS text 2.0.5 Copyright (c) 2010-2012, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/requirejs/text for details
 */
/*jslint regexp: true */
/*global require: false, XMLHttpRequest: false, ActiveXObject: false,
  define: false, window: false, process: false, Packages: false,
  java: false, location: false */
define(["module"],function(e){"use strict";var t,n,r=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"],i=/^\s*<\?xml(\s)+version=[\'\"](\d)*.(\d)*[\'\"](\s)*\?>/im,s=/<body[^>]*>\s*([\s\S]+)\s*<\/body>/im,o=typeof location!=="undefined"&&location.href,u=o&&location.protocol&&location.protocol.replace(/\:/,""),a=o&&location.hostname,f=o&&(location.port||undefined),l=[],c=e.config&&e.config()||{};t={version:"2.0.5",strip:function(e){if(e){e=e.replace(i,"");var t=e.match(s);if(t){e=t[1]}}else{e=""}return e},jsEscape:function(e){return e.replace(/(['\\])/g,"\\$1").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r").replace(/[\u2028]/g,"\\u2028").replace(/[\u2029]/g,"\\u2029")},createXhr:c.createXhr||function(){var e,t,n;if(typeof XMLHttpRequest!=="undefined"){return new XMLHttpRequest}else if(typeof ActiveXObject!=="undefined"){for(t=0;t<3;t+=1){n=r[t];try{e=new ActiveXObject(n)}catch(i){}if(e){r=[n];break}}}return e},parseName:function(e){var t,n,r,i=false,s=e.indexOf("."),o=e.indexOf("./")===0||e.indexOf("../")===0;if(s!==-1&&(!o||s>1)){t=e.substring(0,s);n=e.substring(s+1,e.length)}else{t=e}r=n||t;s=r.indexOf("!");if(s!==-1){i=r.substring(s+1)==="strip";r=r.substring(0,s);if(n){n=r}else{t=r}}return{moduleName:t,ext:n,strip:i}},xdRegExp:/^((\w+)\:)?\/\/([^\/\\]+)/,useXhr:function(e,n,r,i){var s,o,u,a=t.xdRegExp.exec(e);if(!a){return true}s=a[2];o=a[3];o=o.split(":");u=o[1];o=o[0];return(!s||s===n)&&(!o||o.toLowerCase()===r.toLowerCase())&&(!u&&!o||u===i)},finishLoad:function(e,n,r,i){r=n?t.strip(r):r;if(c.isBuild){l[e]=r}i(r)},load:function(e,n,r,i){if(i.isBuild&&!i.inlineText){r();return}c.isBuild=i.isBuild;var s=t.parseName(e),l=s.moduleName+(s.ext?"."+s.ext:""),h=n.toUrl(l),p=c.useXhr||t.useXhr;if(!o||p(h,u,a,f)){t.get(h,function(n){t.finishLoad(e,s.strip,n,r)},function(e){if(r.error){r.error(e)}})}else{n([l],function(e){t.finishLoad(s.moduleName+"."+s.ext,s.strip,e,r)})}},write:function(e,n,r,i){if(l.hasOwnProperty(n)){var s=t.jsEscape(l[n]);r.asModule(e+"!"+n,"define(function () { return '"+s+"';});\n")}},writeFile:function(e,n,r,i,s){var o=t.parseName(n),u=o.ext?"."+o.ext:"",a=o.moduleName+u,f=r.toUrl(o.moduleName+u)+".js";t.load(a,r,function(n){var r=function(e){return i(f,e)};r.asModule=function(e,t){return i.asModule(e,f,t)};t.write(e,a,r,s)},s)}};if(c.env==="node"||!c.env&&typeof process!=="undefined"&&process.versions&&!!process.versions.node){n=require.nodeRequire("fs");t.get=function(e,t){var r=n.readFileSync(e,"utf8");if(r.indexOf("﻿")===0){r=r.substring(1)}t(r)}}else if(c.env==="xhr"||!c.env&&t.createXhr()){t.get=function(e,n,r,i){var s=t.createXhr(),o;s.open("GET",e,true);if(i){for(o in i){if(i.hasOwnProperty(o)){s.setRequestHeader(o.toLowerCase(),i[o])}}}if(c.onXhr){c.onXhr(s,e)}s.onreadystatechange=function(t){var i,o;if(s.readyState===4){i=s.status;if(i>399&&i<600){o=new Error(e+" HTTP status: "+i);o.xhr=s;r(o)}else{n(s.responseText)}}};s.send(null)}}else if(c.env==="rhino"||!c.env&&typeof Packages!=="undefined"&&typeof java!=="undefined"){t.get=function(e,t){var n,r,i="utf-8",s=new java.io.File(e),o=java.lang.System.getProperty("line.separator"),u=new java.io.BufferedReader(new java.io.InputStreamReader(new java.io.FileInputStream(s),i)),a="";try{n=new java.lang.StringBuffer;r=u.readLine();if(r&&r.length()&&r.charAt(0)===65279){r=r.substring(1)}n.append(r);while((r=u.readLine())!==null){n.append(o);n.append(r)}a=String(n.toString())}finally{u.close()}t(a)}}return t})