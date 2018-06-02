# vim-digitme
A Vim plugin to abstract your coding process.

It's meant to be used with project [DigitalMe](#).

## Prerequisite

* vim >= 8.0

## Functionality

### Collect Editing Datas
The whole purpose of this plugin is to capture editor autocmd events. 
When a event gets captured, a corresponding handler would be invoked 
to gather and channel the data to the [DigitalMe](#) client 
running on your local machine.

The following autocmd events would be captured:

- [x] ~~CursorMoved~~
- [x] CursorMovedI
- [x] BufEnter - record the filename, filetype, editing time
- [x] BufLeave
- [ ] VimEnter?
- [ ] VimLeave?
- [ ] InsertEnter?

### Tomato Clock
Pomodoro Timer in Vim

Following user commands are available:

- DigitmeTomatoStart: To start a default timer lasts for 25 minutes 
- DigitmeTomatoPause: To pause a running timer, a timer can only be stop
once
- DigitmeTomatoAbandon: To abandon the current timer

* [ ] A dedicated window to setup, teardown timers
* [x] Integrate with lightline

## Use Case

This plugin together with the [DigitalMe](#) client would help you to 
answer some questions that you might be interested in:

- How often do you code?
- How fast do you code?
- When do you code often?
- What languages do you usually deal with?

You can also use the plugin to drive your own applications.
