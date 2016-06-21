export class Logger {
  constructor(writer = {write() {
    console.log(...arguments);
  }}) {
    this.writer = writer;
  }
  info(tag, body) {
    let [_tag, _body] = (arguments.length >= 2) ? [tag, body] : [this.fromStack(), tag];
    this.writer.write(`%c[${_tag}]%c`, 'color: blue; font-weight: bold;', '', _body);
  }
  warn(tag, body) {
    console.log(this.fromStack());
    let [_tag, _body] = (arguments.length >= 2) ? [tag, body] : [this.fromStack(), tag];
    this.writer.write(`%c[${_tag }]%c`, 'color: orange; font-weight: bold;', '', _body);
  }
  fromStack(depth = 3) {
    return (new Error()).stack.split('\n')[depth].trim();//.split(' ').slice(0,2).join(' ')
  }
}