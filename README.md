# vim-digitme
A Vim plugin to abstract your coding process.

A data collector for project [DigitalMe](https://github.com/DingDean/DigitalMe)

## Prerequisite

* vim >= 8.0
* [lightline](https://github.com/itchyny/lightline.vim)
* [digitme-cli](https://github.com/DingDean/client-digitalme)

## Functionalities

This plugin together with the [digitme-cli](https://github.com/DingDean/client-digitalme) client would help you to 
answer some questions that you might be interested in:

- How often do you code?
- How fast do you code?
- When do you code often?
- What languages do you usually deal with?

### Collect Editing Datas
The whole purpose of this plugin is to capture editor autocmd events. 
When a event gets captured, a corresponding handler would be invoked 
to gather and channel the data to the [digitme-cli](https://github.com/DingDean/client-digitalme) client 
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

## Installation

It's recommended to install the plugin with popular vim plugin manager,
like [vundle](https://github.com/VundleVim/Vundle.vim) or [neo-bundle](https://github.com/Shougo/neobundle.vim).

For vundle, it's as easy as adding the following line to your vim.rc and
then run `PluginInstall`:

`Plugin 'DingDean/vim-digitme'`

## Configuration

The following configuration is available:

`g:digitme#clientUrl`:

- description: the endpoint where the vim channel would connect to
- default: 'localhost:8763'
