Manifest for Android KitKat / CyanogenMod 11.0
====================================
Project M4|L5 / Project U0|L7 / Project V1|L1II / Project Vee3|L3II

---

Automatic Way:

script to download manifests, sync repo and build:

    curl --create-dirs -L -o build.sh -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-11.0/build.sh

To use:

    source build.sh

---

Manual Way:

To initialize CyanogenMod 11.0 Repo:

    repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0 -g all,-notdefault,-darwin

---

To initialize MSM7x27a Manifest for all devices:

    curl --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-11.0/msm7x27a_manifest.xml

---

To initialize Manifest for L5/L7:

    curl --create-dirs -L -o .repo/local_manifests/gen1_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-11.0/gen1_manifest.xml

---

To initialize Manifest for L1II/L3II:

    curl --create-dirs -L -o .repo/local_manifests/gen2_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-11.0/gen2_manifest.xml

---

# Never use 'L5/L7' Manifest with 'L1II/L3II' Manifest

---

Sync the repo:

    repo sync -c --force-sync

---

Initialize the environment:

    source build/envsetup.sh

---

To build for L5:

    brunch e610

---

To build for L7:

    brunch p700

---

To build for L1II:

    sh device/lge/v1/patches/apply.sh
    brunch v1

---

To build for L3II:

    sh device/lge/vee3/patches/apply.sh
    brunch vee3
