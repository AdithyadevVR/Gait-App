window.requestSerialPort = async function () {
    try {
        window.serialPort = await navigator.serial.requestPort();
        await window.serialPort.open({ baudRate: 115200 });
        window.serialReadLoop();
        return true;
    } catch (e) {
        console.error("Serial Port request failed:", e);
        return false;
    }
};

window.disconnectSerialJS = async function () {
    if (window.serialReader) {
        await window.serialReader.cancel();
        window.serialReader = null;
    }
    if (window.serialPort) {
        await window.serialPort.close();
        window.serialPort = null;
    }
};

window.serialReadLoop = async function () {
    if (!window.serialPort) return;
    const textDecoder = new TextDecoderStream();
    window.serialPort.readable.pipeTo(textDecoder.writable);
    window.serialReader = textDecoder.readable.getReader();
    let buffer = "";

    try {
        while (true) {
            const { value, done } = await window.serialReader.read();
            if (done) break;
            if (value) {
                buffer += value;
                let lines = buffer.split('\n');
                buffer = lines.pop(); // Keep incomplete line
                for (let line of lines) {
                    line = line.trim();
                    if (line && window.onSerialLineReceived) {
                        window.onSerialLineReceived(line);
                    }
                }
            }
        }
    } catch (error) {
        console.error("Serial read error:", error);
    } finally {
        if (window.serialReader) {
            window.serialReader.releaseLock();
            window.serialReader = null;
        }
        if (window.onSerialDisconnect) {
            window.onSerialDisconnect();
        }
    }
};
