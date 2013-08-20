use core::task::spawn;
use core::comm::{stream,Port,Chan,SharedChan};

macro_rules! compute_and_send(
    ($inp:expr, $port:ident) => (
        do spawn {
            $port.send($inp);
        }
    );
)

fn main() {
    let (out,in): (Port<int>, Chan<int>) = stream();
    let in = SharedChan(in);
    let (strout,strin): (Port<~str>, Chan<~str>) = stream();

    do spawn {
        let x = out.recv();
        let y = out.recv();
        let z = out.recv();
        let result = fmt!("%d + %d + %d = %d", x, y, z, x+y+z);
        strin.send(result);
    }

    let (in1, in2, in3) = (in.clone(), in.clone(), in.clone());
    compute_and_send!(2 * 10, in1);
    compute_and_send!(2 * 20, in2);
    compute_and_send!(30 + 40, in3);

    let result = strout.recv();
    io::println(result);
}