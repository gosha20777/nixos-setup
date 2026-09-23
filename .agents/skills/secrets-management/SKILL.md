---
name: secrets-management
description: Manage, encrypt, rotate, and consume secrets in this NixOS flake using sops-nix and Age. Enforces zero-leak security rules, single master Age key architecture, and strict agent workflow (read -> ask -> plan -> approval -> execute).
---

# Secrets Management Skill (`sops-nix` + Age)

Use this skill whenever adding, updating, rotating, or troubleshooting secrets in this repository (e.g. API keys for AI coding agents, private SSH keys, OAuth tokens, credentials).

---

## 1. Architecture Overview

This repository uses **`sops-nix`** with a **Single User Age Master Key** architecture:

1. **Age Master Key (Identity Key):**
   - Resides strictly outside of Git in `~/.config/sops/age/keys.txt` (permissions `0600`).
   - Format: `AGE-SECRET-KEY-1...`.
   - The master key belongs to the user (`gosha20777`), NOT to an ephemeral host. When a machine is reinstalled or replaced, the Git repo does NOT need re-encryption; copying `keys.txt` restores all access immediately.
   - **CRITICAL:** The contents of `keys.txt` are top-secret and MUST NEVER be staged, committed, or leaked into Git.

2. **Public Key & Encryption Routing (`.sops.yaml`):**
   - Located at the repository root.
   - Holds the public Age key (`age1...`) using the anchor `&gosha20777`.
   - Routing rules define which files are encrypted with this key:
     ```yaml
     keys:
       - &gosha20777 age1z23l5wjy6lrma8m7tp6dysydwcqg0fvgfwnxq59233mfhwylxscss7hfld

     creation_rules:
       - path_regex: secrets/.*\.yaml$
         key_groups:
           - age:
               - *gosha20777
     ```

3. **Separation of Secrets:**
   - **`secrets/common.yaml`**: Shared across all machines (e.g. Oh My Pi API keys: OpenRouter, Ollama, Exa, Tavily).
   - **`secrets/<hostname>.yaml`** (e.g. `secrets/thinkpad.yaml`): Host-specific secrets (e.g. the specific machine's private SSH key `id_ed25519`).

4. **NixOS & Home-Manager Wiring:**
   - Central Home Manager configuration: `modules/home/system/sops.nix` sets `defaultSopsFile = ../../../secrets/common.yaml` and `age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt"`.
   - Secrets consumption in modules: `sops.secrets.<name> = { ... };`.
   - Generating environment files: `sops.templates."<name>" = { path = "..."; content = "..."; };`.

---

## 2. Mandatory Protocol for AI Models / Agents

Any agent modifying or adding secrets MUST follow this strict 5-stage protocol:

### Stage 1: Read and Inspect
- Read `.sops.yaml` to verify active public keys and creation rules.
- Read `secrets/common.yaml` and any target `secrets/<host>.yaml` (encrypted headers).
- Inspect the module consuming the secret (e.g. `modules/home/agents/oh-my-pi.nix` or `hosts/<host>/home.nix`).
- Check if `~/.config/sops/age/keys.txt` exists and matches the public key in `.sops.yaml`.
- **Never guess key names or formats.**

### Stage 2: Clarification (Ask User)
- If the scope of a new secret (shared vs host-specific) is ambiguous, ask the user.
- If a required secret value is missing, prompt the user for the plaintext or where to extract it.

### Stage 3: Write Detailed Plan
- Detail the exact files to create or modify.
- Detail the exact command for encryption (`sops --encrypt`).
- Detail the module consumer (`sops.secrets` or `sops.templates`).
- Detail how round-trip decryption verification will be conducted.

### Stage 4: User Approval Gate
- **NEVER execute changes or write secrets before the user explicitly approves the plan.**

### Stage 5: Execution, Verification & Zero-Leak Rules
- Execute using `nix shell nixpkgs#sops nixpkgs#age` if local CLI tools are not installed globally.
- **Verification:** Immediately decrypt the newly encrypted file (`sops -d`) and assert that the decrypted plaintext matches the original input 100%.
- **Verification:** Run `nix eval --raw "path:.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath"` to guarantee Nix can evaluate the secret bindings.
- **NEVER commit automatically:** Git commits are performed ONLY upon explicit user command.

---

## 3. Operational Reference Commands

```bash
# Encrypt a new YAML file using SOPS and Age:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops --encrypt --filename-override secrets/common.yaml /path/to/plaintext.yaml > secrets/common.yaml

# Edit an existing encrypted file interactively:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops secrets/common.yaml

# Decrypt to stdout for verification:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops -d --output-type json secrets/common.yaml

# Re-encrypt in-place after updating .sops.yaml rules:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops updatekeys secrets/common.yaml
```
