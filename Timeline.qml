import QtQuick 2.15

Rectangle {
    id: root
    property var hours_format: 24;
    property var minutes_per_step: [1, 2, 5, 10, 15, 20, 30, 60, 120, 180, 240, 360, 720, 1440];
    property var graduation_step: 10;
    property var distance_between_gtitle: 80;
    property var start_timestamp: new Date().getTime() - (new Date().getHours() + new Date().getMinutes()/60)*60*60*1000;
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
            MouseArea {
                id: timelineHover
                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: parent.height + 40
                hoverEnabled: true
            }
        }
        Canvas {
            id: timelineCanvas
            anchors.fill: parent
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

    function add_graduations(start_timestamp){
        let ctx = timelineCanvas.getContext("2d")
        var px_per_min = timelineContainer.width / (hours_format * 60); // px/min
        var px_per_ms = timelineContainer.width / (hours_format * 60 * 60 * 1000); // px/ms
        var px_per_step = graduation_step;  // px/格 默认最小值20px
        var min_per_step = px_per_step / px_per_min; // min/格
        for(var i = 0; i < minutes_per_step.length;i++){
            if(min_per_step <= minutes_per_step[i]){ //让每格时间在minutes_per_step规定的范围内
                min_per_step = minutes_per_step[i];
                px_per_step = px_per_min * min_per_step;
                break
            }
        }

        var medium_step = 30;
        for (var i = 0; i < minutes_per_step.length; i++) {
            if (distance_between_gtitle / px_per_min <= minutes_per_step[i]) {
                medium_step = minutes_per_step[i];
                break;
            }
        }

        var num_steps = timelineContainer.width / px_per_step; //总格数
        var graduation_left;
        var graduation_time;
        var caret_class;
        var lineH;
        var ms_offset = ms_to_next_step(start_timestamp,min_per_step*60*1000);//开始的偏移时间 ms
        var px_offset = ms_offset * px_per_ms; //开始的偏移距离 px
        var ms_per_step = px_per_step / px_per_ms; // ms/step
        for(var i = 0; i < num_steps; ++i){
            graduation_left = px_offset + i * px_per_step; // 距离=开始的偏移距离+格数*px/格
            graduation_time = start_timestamp + ms_offset + i * ms_per_step; //时间=左侧开始时间+偏移时间+格数*ms/格
            var date = new Date(graduation_time);
            if (date.getUTCHours() == 0 && date.getUTCMinutes() == 0) {
                caret_class = 'big';
                lineH = 8;
                var big_date = graduation_title(date);
                ctx.fillText(big_date,graduation_left-20,timelineContainer.y +timelineContainer.height + 20 + lineH);
                ctx.fillStyle = "#E8E8E8";
            }else if (graduation_time / (60 * 1000) % medium_step == 0) {
                caret_class = 'middle';
                lineH = 8;
                var middle_date = graduation_title(date);
                ctx.font = 'normal 11px sans-serif';
                ctx.fillText(middle_date,graduation_left-15,timelineContainer.y +timelineContainer.height + 20 + lineH);
                ctx.fillStyle = "#E8E8E8";
            }else{
                lineH = 3;
            }
            // drawLine(graduation_left,0,graduation_left,lineH,"rgba(151,158,167,0.4)",1);
            drawLine(graduation_left,timelineContainer.y +timelineContainer.height + 10,graduation_left,timelineContainer.y +timelineContainer.height + 10 + lineH,"#3F434D",1);
        }
    }
    function ms_to_next_step(timestamp, step) {
        var remainder = timestamp % step;
        return remainder ? step - remainder : 0;
    }
    function graduation_title(datetime) {
        if (datetime.getHours() == 0 && datetime.getMinutes() == 0 && datetime.getMilliseconds() == 0) {
            return ('0' + datetime.getDate().toString()).substr(-2) + '.' +
                ('0' + (datetime.getMonth() + 1).toString()).substr(-2) + '.' +
                datetime.getFullYear();
        }
        return datetime.getHours() + ':' + ('0' + datetime.getMinutes().toString()).substr(-2);
    }
}
