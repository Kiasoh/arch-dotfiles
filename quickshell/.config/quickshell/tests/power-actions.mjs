// Exercise the QML's own functions with only the process boundary replaced.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';

const backend = readFileSync(new URL('../PowerState.qml', import.meta.url), 'utf8');
const icon = readFileSync(new URL('../Power.qml', import.meta.url), 'utf8');
function setup() {
    const context = vm.createContext({
        root: {busy: false, note: '', noteError: '', rebootNeeded: false,
               pendingGpu: '', actionKind: '', refresh() {}},
        actionProc: {running: false},
        Quickshell: {shellPath: p => '/config/' + p},
    });
    context.hardware = context.root;
    for (const name of ['runAction', 'confirmGpu', 'finishAction', 'setRefresh', 'setGaps', 'setOption', 'gapLiteral']) {
        const source = name === 'confirmGpu' ? icon : backend;
        const start = source.indexOf('function ' + name + '(');
        assert.notEqual(start, -1, 'Missing behavior: ' + name);
        let end = source.indexOf('{', start), depth = 1;
        while (depth && ++end < source.length) {
            if (source[end] === '{') depth++;
            if (source[end] === '}') depth--;
        }
        vm.runInContext(source.slice(start, end + 1), context);
        context.root[name] = context[name];
    }
    return context;
}

const c = setup();
c.root.pendingGpu = 'integrated';
assert.equal(c.actionProc.running, false, 'Selecting GPU must not start a process');
c.root.confirmGpu();
assert.deepEqual(Array.from(c.actionProc.command), ['pkexec', '/config/scripts/qs-gpu-mode.sh', 'integrated']);
c.root.runAction(['bad'], 'other');
assert.equal(c.actionProc.command[0], 'pkexec', 'Busy action must not be replaced');
c.root.finishAction(126, '');
assert.equal(c.root.busy, false);
assert.equal(c.root.rebootNeeded, false, 'Cancelled GPU action must not require reboot');
assert.ok(c.root.noteError.length);
c.root.pendingGpu = 'hybrid';
c.root.confirmGpu();
c.root.finishAction(1, 'denied');
assert.equal(c.root.noteError, 'denied');
assert.equal(c.root.rebootNeeded, false);
c.root.pendingGpu = 'nvidia';
c.root.confirmGpu();
c.root.finishAction(0, '');
assert.equal(c.root.rebootNeeded, true);
c.root.runAction(['tlp'], 'tlp');
c.root.finishAction(0, '');
assert.equal(c.root.rebootNeeded, true, 'TLP must not clear the GPU notice');

c.root.monitor = {name: 'HDMI-A-1', width: 2560, height: 1440,
                  transform: 0, refreshRate: 59.94, x: 1920, y: -100, scale: 1.25};
c.root.setRefresh('2560x1440@59.94Hz');
assert.equal(c.actionProc.command[2], 'hl.monitor({output="HDMI-A-1",mode="2560x1440@59.94",position="1920x-100",scale=1.25,transform=0})');
c.root.finishAction(0, '', 'ok');
c.root.hyprState = {'general:gaps_in': '3 4 5 6', 'general:gaps_out': '4 8 12 16'};
c.root.setGaps(false);
assert.equal(c.actionProc.command[2], 'hl.config({general={gaps_in=0,gaps_out=0}})');
c.root.finishAction(0, '', 'ok');
c.root.setGaps(true);
assert.equal(c.actionProc.command[2], 'hl.config({general={gaps_in={top=3,right=4,bottom=5,left=6},gaps_out={top=4,right=8,bottom=12,left=16}}})');
c.root.finishAction(0, '', 'ok');
c.root.setOption('decoration:blur:enabled', false);
assert.equal(c.actionProc.command[2], 'hl.config({["decoration.blur.enabled"]=false})');
c.root.finishAction(0, '', 'unknown request');
assert.equal(c.root.note, '', 'Rejected Hyprland command must not report success');
assert.equal(c.root.noteError, 'unknown request');
console.log('Power action regression checks passed');
