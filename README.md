Manifest for Android MarshMallow / CyanogenMod 13.0
====================================
Project M4|L5 / Project U0|L7 / Project V1|L1II / Project Vee3|L3II

---

Automatic Way:

script to download manifests, sync repo and build:

    curl --create-dirs -L -o build.sh -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-13.0/build.sh

To use:

    source build.sh

---

Manual Way:

To initialize CyanogenMod 13.0 Repo:

    repo init -u git://github.com/CyanogenMod/android.git -b cm-13.0 -g all,-notdefault,-darwin

---

To initialize MSM7x27a Manifest for all devices:

    curl --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-13.0/msm7x27a_manifest.xml

---

To initialize Manifest for L5/L7:

    curl --create-dirs -L -o .repo/local_manifests/gen1_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-13.0/gen1_manifest.xml

---

To initialize Manifest for L1II/L3II:

    curl --create-dirs -L -o .repo/local_manifests/gen2_manifest.xml -O -L https://raw.github.com/TeamHackLG/local_manifest/cm-13.0/gen2_manifest.xml

---

# Never use 'L5/L7' Manifest with 'L1II/L3II' Manifest

---

Initialize the environment:

    source build/envsetup.sh

---

Use this 'repo sync' because it use "Parallel repo sync using ionice and SCHED_BATCH", after initialize of the environment:

    reposync

---

Initialize the environment:

    source build/envsetup.sh

---

Apply patchs for ALL devices:

    repopick 144710 144831 144976

---

To build for L5:

    brunch e610

---

To build for L7:

    brunch p700

---

To build for L1II:

    brunch v1

---

To build for L3II:

    brunch vee3
