import QtQuick 2.15

Rectangle {
    id: root
    property var hours_format: 24;
    property var minutes_per_step: [1, 2, 5, 10, 15, 20, 30, 60, 120, 180, 240, 360, 720, 1440];
    property var graduation_step: 10;
    property var distance_between_gtitle: 80;
    property var start_timestamp: new Date().getTime() - (new Date().getHours() + new Date().getMinutes()/60)*60*60*1000;
    property var zoom: 24;
    height: 149
    color: "#15161A"
    Item {
        id: tlHudContainer
        anchors {
            top: parent.top
            left: parent.left
            right:parent.right
        }
        height: 97
        Item {
            id: timelineContainer
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 35
            }
            height: 20
            Timer {
                id: timer
                interval: 25
                repeat: false
                running: false
                triggeredOnStart: false
//                onTriggered: {
//                    root.moveSpeed.z = 0
//                }
            }

            MouseArea {
                id: timelineHover
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: parent.height + 40
                hoverEnabled: true
                onExited: {
                    timelineCanvas.clearCanvas()
                    init()
                }

                onPositionChanged: {
                    if(!timer.running) {
                        timer.start()
                        var px_per_ms = timelineContainer.width / (hours_format * 60 * 60 * 1000); // px/ms
                        let ctx = timelineCanvas.getContext("2d")
                        timelineCanvas.clearCanvas()
                        var time = start_timestamp + mouseX/px_per_ms;
                        init(start_timestamp);
                        drawLine(mouseX,timelineContainer.y - 10,mouseX,timelineContainer.y + 50,"rgb(194, 202, 215)",1);
                        ctx.fillStyle = "rgb(194, 202, 215)";
                        ctx.fillText(getTimeUnderCursor(time),mouseX - 20,timelineContainer.y + 61);
                    }
                }

                onWheel: {
                    wheel.accepted=true
                    var middle_time = start_timestamp + (hours_format*3600*1000)/2;
                    if(wheel.angleDelta.y > 0) {
                        if(zoom > 4) {
                            zoom = zoom - 4
                        } else if(zoom < 0.1) {
                            zoom = 0.05
                        }  else {
                            zoom = zoom - 0.4
                        }

                        hours_format = zoom;
                    } else if (wheel.angleDelta.y < 0) {
                        if (zoom >= 24) {
                            zoom = 24;
                        } else if(zoom > 4) {
                            zoom = zoom + 4
                        } else {
                            zoom = zoom + 0.4
                        }

                        hours_format = zoom;
                    }
                    let ctx = timelineCanvas.getContext("2d")
                    timelineCanvas.clearCanvas()
                    start_timestamp = middle_time - (hours_format*3600*1000)/2;
                    init()
                }
            }
        }
        Canvas {
            id: timelineCanvas
            anchors.fill: parent
            function clearCanvas() {
                var ctx = getContext("2d");
                ctx.reset();
                timelineCanvas.requestPaint();
            }

            onPaint: {
//                var ctx = getContext("2d")
                // setup your path
                // fill or/and stroke
            }
            onAvailableChanged: {
                fillRect()
                drawTopLane()
                drawBottomLane()
                add_graduations(start_timestamp)
            }
        }
    }
    function getTimeUnderCursor(time) {
        return new Date(time).toLocaleTimeString()
    }

    function draw_cell(){
        var px_per_ms = timelineCanvas.width / (hours_format * 60 * 60 * 1000); // px/ms
        var beginTime = new Date()
        beginTime.setHours(0,0,0)
        beginTime.setMilliseconds(0)
        let ctx = timelineCanvas.getContext("2d")
        for(var i = 0; i < 2000; ++i) {
            var endTime = beginTime
            endTime = new Date(beginTime.getTime() + 20000)
            var beginX = (beginTime - start_timestamp) * px_per_ms;
            var cell_width = (endTime.getTime() - beginTime.getTime()) * px_per_ms;
            ctx.fillStyle = 'red'
            ctx.strokeStyle = "blue"
            //console.log(cell_width, endTime.getTime(), beginTime.getTime(), beginTime.getSeconds()+20)
            ctx.fillRect(beginX,timelineContainer.y,cell_width,timelineContainer.height);
            beginTime = new Date(beginTime.getTime() + 30000)
            //console.log(Math.round(beginX),timelineContainer.y,cell_width,timelineContainer.height)
        }


    }

    function init() {
        drawTopLane()
        drawBottomLane()
        fillRect()
        add_graduations(start_timestamp)
        draw_cell()
    }

    function fillRect() {
        let cx = timelineCanvas.getContext("2d")
        cx.fillStyle = '#1E2024'
        cx.strokeStyle = "blue"
        cx.lineWidth = 4
        cx.fillRect(timelineContainer.x, timelineContainer.y, timelineContainer.width, timelineContainer.height)
    }
    function drawTopLane() {
        let cx = timelineCanvas.getContext("2d")
        cx.strokeStyle = "#3F434D"
        cx.lineWidth = 1
        cx.beginPath();
        cx.moveTo(timelineContainer.x, timelineContainer.y - 10)
        cx.lineTo(timelineContainer.x + timelineContainer.width, timelineContainer.y - 10)
        //timelineCanvas.requestPaint()
        cx.stroke();
    }
    function drawBottomLane() {
        let cx = timelineCanvas.getContext("2d")
        cx.strokeStyle = "#3F434D"
        cx.lineWidth = 1
        cx.beginPath();
        cx.moveTo(timelineContainer.x, timelineContainer.y +timelineContainer.height + 10)
        cx.lineTo(timelineContainer.x + timelineContainer.width, timelineContainer.y +timelineContainer.height + 10)
        //timelineCanvas.requestPaint()
        cx.stroke();
    }
    function drawLine(beginX,beginY,endX,endY,color,width){
        let ctx = timelineCanvas.getContext("2d")
        ctx.beginPath();
        ctx.moveTo(beginX,beginY);
        ctx.lineTo(endX,endY);
        ctx.strokeStyle = color;
        ctx.lineWidth = width;
        ctx.stroke();
    }

    function getPixelsPerMinute() {
      return timelineContainer.width / (hours_format * 60);
    }

    function getPixelsPerMillisecond() {
       return timelineContainer.width / (hours_format * 60 * 60 * 1000);
    }

    function add_graduations(start_timestamp = new Date().getTime() - (new Date().getHours() + new Date().getMinutes()/60)*60*60*1000){
        const ctx = timelineCanvas.getContext("2d")
        const px_per_min = getPixelsPerMinute()
        const px_per_ms = getPixelsPerMillisecond()
        let px_per_step = graduation_step;
        let min_per_step = px_per_step / px_per_min;
        for(var i = 0; i < minutes_per_step.length;++i){
            if(min_per_step <= minutes_per_step[i]){
                min_per_step = minutes_per_step[i];
                px_per_step = px_per_min * min_per_step;
                break
            }
        }

        var medium_step = 30;
        for (let j = 0; j < minutes_per_step.length; ++j) {
            if (distance_between_gtitle / px_per_min <= minutes_per_step[j]) {
                medium_step = minutes_per_step[j];
                break;
            }
        }

        const num_steps = timelineContainer.width / px_per_step;
        var graduation_left;
        var graduation_time;
        var caret_class;
        var heightOfLine;
        const ms_offset = ms_to_next_step(start_timestamp,min_per_step*60*1000);
        const px_offset = ms_offset * px_per_ms;
        const ms_per_step = px_per_step / px_per_ms;
        for(let i = 0; i < num_steps; ++i){
            graduation_left = px_offset + i * px_per_step;
            graduation_time = start_timestamp + ms_offset + i * ms_per_step;
            var date = new Date(graduation_time);
            if (date.getUTCHours() == 0 && date.getUTCMinutes() == 0) {
                caret_class = 'big';
                heightOfLine = 8;
                var big_date = graduation_title(date);
                ctx.fillStyle = "#E8E8E8";
                ctx.fillText(big_date,graduation_left-15,timelineContainer.y +timelineContainer.height + 20 + heightOfLine);
            }else if (graduation_time / (60 * 1000) % medium_step == 0) {
                caret_class = 'middle';
                heightOfLine = 8;
                const middle_date = graduation_title(date);
                ctx.font = 'normal 11px sans-serif';
                ctx.fillStyle = "#E8E8E8";
                ctx.fillText(middle_date,graduation_left-15,timelineContainer.y + timelineContainer.height + 20 + heightOfLine);

            }else{
                heightOfLine = 3;
            }
            drawLine(graduation_left,timelineContainer.y +timelineContainer.height + 10,graduation_left,timelineContainer.y +timelineContainer.height + 10 + heightOfLine,"#3F434D",1);
        }
    }
    function ms_to_next_step(timestamp, step) {
        var remainder = timestamp % step;
        return remainder ? step - remainder : 0;
    }
    function graduation_title(datetime) {
//        if (datetime.getHours() === 0 && datetime.getMinutes() === 0 && datetime.getMilliseconds() === 0) {
//            return ('0' + datetime.getDate().toString()).substr(-2) + '.' +
//                ('0' + (datetime.getMonth() + 1).toString()).substr(-2) + '.' +
//                datetime.getFullYear();
//        }
        return datetime.getHours() + ':' + ('0' + datetime.getMinutes().toString()).substr(-2);
    }
}
