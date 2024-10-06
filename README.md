
### CUSTOM! GExpertsBPL - custom GExperts based on gexperts-r4314-trunk.

A playground. The changes are properly described in the commit messages.

---
### Summary:

- GExperts framework build as BPL package - without experts, without IDE and editor enhancements.

    You can rebuild and see your changes immediately without restarting RAD Studio.

    Some initializations and dependencies were resolved.

    Minor changes in GExpertsDebugWindow.


- List of currently enabled/included experts: GX_FocusCodeEditor, GX_IdeShortCuts, GX_KeyboardShortcuts, GX_ProjDepend.


- Fixed bug - With RAD Studio 12.1, 'IOTAKeyboardBinding.BindKeyboard' is called on rebuild/unload/install a 'ToolsApi' project.
In GExperts, this triggers multiple 'Add/Remove' shortcut activities. And GExperts key mappings is removed.


- Updated GX_KeyboardShortcuts (work in progress).


- Updated experts order in GX_Experts.ExpertIndexLookup.

---

### Ideas:

- Integration of RAD Studio and IntelliJ. (I use IntelliJ as a git client and I have to switch often between both applications).

- Shortcuts - all in one place. Merge 'IDE Menu Shortcuts' and 'Keyboard Shortcuts'. Information for Delphi default Key mappings.

- Units initialization order (only for units with 'initialization/finalization' section). Units circular references.
  - Project Dependencies - scope to project dir/units in the project, expand all, highlight/filter/find circular references.
  - Uses Clause Manager and Pascal parser thread - scope to project dir/units only, On/Off switch for the background thread, (notification before the first start).

- Reorder Experts (move up/down) in menu and configuration window.

---

![image](https://github.com/user-attachments/assets/05912e9b-4569-4c38-9734-44e4a309a983)

![image](https://github.com/user-attachments/assets/ba39f3c4-c3df-41cc-838d-4062e89a221e)

![image](https://github.com/user-attachments/assets/36542e21-a9f0-4ee0-9e20-5657c473dae2)

![image](https://github.com/user-attachments/assets/75a96c53-9a70-4f0d-830c-1cc2d09eda38)

![image](https://github.com/user-attachments/assets/c0a48a89-9a78-488a-b7cc-85783127e54c)

