{
  stdenv,
  lib,
  fetchFromGitHub,
  gnat,
  gprbuild,
}:

stdenv.mkDerivation {
  pname = "atomic";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Fabien-Chouteau";
    repo = "atomic";
    rev = "v1.0.0";
    hash = "sha256-b/TJlbsCClGB+gfI5FLGw7jaaxUneY0z84JpjTq9THk=";
  };

  nativeBuildInputs = [
    gnat
    gprbuild
  ];

  # This configuration is from config/atomic_config.gpr
  # when building `atomic` with `alr build`.
  configurePhase = ''
    mkdir -p config
    cat > config/atomic_config.gpr << 'EOF'
    abstract project Atomic_Config is
      Crate_Version := "1.2.0-dev";
      Crate_Name := "atomic";

      Alire_Host_OS := "linux";

      Alire_Host_Arch := "x86_64";

      Alire_Host_Distro := "distribution_unknown";
      Ada_Compiler_Switches := External_As_List ("ADAFLAGS", " ");
      Ada_Compiler_Switches := Ada_Compiler_Switches &
              (
                "-Og" -- Optimize for debug
              ,"-ffunction-sections" -- Separate ELF section for each function
              ,"-fdata-sections" -- Separate ELF section for each variable
              ,"-g" -- Generate debug info
              ,"-gnatwa" -- Enable all warnings
              ,"-gnatw.X" -- Disable warnings for No_Exception_Propagation
              ,"-gnatVa" -- All validity checks
              ,"-gnaty3" -- Specify indentation level of 3
              ,"-gnatya" -- Check attribute casing
              ,"-gnatyA" -- Use of array index numbers in array attributes
              ,"-gnatyB" -- Check Boolean operators
              ,"-gnatyb" -- Blanks not allowed at statement end
              ,"-gnatyc" -- Check comments
              ,"-gnaty-d" -- Disable check no DOS line terminators present
              ,"-gnatye" -- Check end/exit labels
              ,"-gnatyf" -- No form feeds or vertical tabs
              ,"-gnatyh" -- No horizontal tabs
              ,"-gnatyi" -- Check if-then layout
              ,"-gnatyI" -- check mode IN keywords
              ,"-gnatyk" -- Check keyword casing
              ,"-gnatyl" -- Check layout
              ,"-gnatym" -- Check maximum line length
              ,"-gnatyn" -- Check casing of entities in Standard
              ,"-gnatyO" -- Check that overriding subprograms are explicitly marked as such
              ,"-gnatyp" -- Check pragma casing
              ,"-gnatyr" -- Check identifier references casing
              ,"-gnatyS" -- Check no statements after THEN/ELSE
              ,"-gnatyt" -- Check token spacing
              ,"-gnatyu" -- Check unnecessary blank lines
              ,"-gnatyx" -- Check extra parentheses
              ,"-gnatW8" -- UTF-8 encoding for wide characters
              );

      RP2040_Spinlock_ID_First := "0";
      RP2040_Spinlock_ID_Last := "31";
      RP2040_Spinlock_ID := "31";

      type Backend_Kind is ("Intrinsic", "armv6m", "rp2040_spinlock");
      Backend : Backend_Kind := "Intrinsic";

      type Build_Profile_Kind is ("release", "validation", "development");
      Build_Profile : Build_Profile_Kind := "development";

    end Atomic_Config;
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    gprbuild -p atomic.gpr
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    gprinstall -P atomic.gpr --prefix=$out \
      --no-manifest \
      --mode=dev \
      -p
    runHook postInstall
  '';

  meta = {
    description = "Standalone Ada/SPARK bindings to GCC atomic built-ins";
    homepage = "https://github.com/Fabien-Chouteau/atomic";
    maintainers = [ lib.maintainers.candreano ];
    license = lib.licenses.mit;

    # TODO: is this actually true
    platforms = lib.platforms.all;
  };
}
