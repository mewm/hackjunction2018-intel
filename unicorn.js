let { spawn } = require("child_process");
const fs = require("fs");
const axios = require("axios");
class Unicorn {
  constructor() {
    this.threshold = 28;
    this.start();
  }

  start() {
    // const nodes = ["0x0001", "0x0002", "0x0003"];
    const nodes = ["0x0001"];

    nodes.forEach(node => {
      this.temp_timer = setInterval(() => {
        let python = spawn("/usr/bin/python3", [
          "/home/jnct/team2/get_temperature.py",
          node
        ]);
        // console.log("Initiated temperature write for node " + node);
        setTimeout(function() {
          // console.log("killed something");
          python.kill(1);
        }, 2000);
      }, 2000);
    });

    let did_just_run = false;
    nodes.forEach(node => {
      setInterval(() => {
        let filename = "temp_node_" + node.substr(-1) + ".txt";
        // console.log(filename);s
        fs.readFile(filename, "utf8", (err, contents) => {
          let payload = {
            temperature: contents,
            node: node.substr(-1)
          };
            axios.post('', payload).then(result => {
              console.log(payload);
            }).catch(err => {
                console.log('ERRRP');
            });

          if (contents > this.threshold) {
            console.log("ALARMA!");
            if (did_just_run === false) {
              clearInterval(this.temp_timer);
              console.log("Inner !");
              setTimeout(function() {
                  console.log('timeout');
                spawn("/usr/bin/python3", [
                  "/home/jnct/team2/alarm.py",
                  "0xc123",
                  "ALARMA!"
                ]);
              }, 3000);
              did_just_run = true;
              // setTimeout(() => {
              //   console.log('Ready to go off again');
              //   did_just_run = false;
              // }, 10000);
            }
          }
        });
      }, 2000);
    });
  }
}

const unicorn = new Unicorn();
