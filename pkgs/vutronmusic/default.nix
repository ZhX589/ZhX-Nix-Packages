{ stdenv
, lib
, fetchFromGitHub
, nodejs_22
, yarn
, electron_33
, makeWrapper
, python3
, sqlite
, ...
}:

stdenv.mkDerivation rec {
  pname = "vutronmusic";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "stark81";
    repo = "VutronMusic";
    rev = "v${version}";
    sha256 = lib.fakeSha256;  # 第一次构建后替换
  };

  nativeBuildInputs = [ nodejs_22 yarn makeWrapper python3 ];

  buildInputs = [ sqlite ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    
    # 配置 yarn 使用淘宝镜像（在中国加速）
    yarn config set registry https://registry.npmmirror.com
    
    # 安装依赖
    yarn install --frozen-lockfile --ignore-engines --network-timeout 100000
    
    # 构建
    yarn build
  '';

  installPhase = ''
    mkdir -p $out/bin $out/opt/vutronmusic
    
    # 复制构建产物
    if [ -d "dist" ]; then
      cp -r dist/* $out/opt/vutronmusic/
    elif [ -d "build" ]; then
      cp -r build/* $out/opt/vutronmusic/
    else
      echo "Error: Build output not found"
      find . -maxdepth 2 -type d
      exit 1
    fi
    
    # 创建启动脚本
    makeWrapper ${electron_33}/bin/electron $out/bin/vutronmusic \
      --argv0 "vutronmusic" \
      --add-flags "$out/opt/vutronmusic" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ sqlite ]}
    
    # 安装桌面文件
    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
    
    cat > $out/share/applications/vutronmusic.desktop << EOF
    [Desktop Entry]
    Name=VutronMusic
    Comment=多数据源桌面音乐播放器
    Exec=$out/bin/vutronmusic
    Icon=vutronmusic
    Terminal=false
    Type=Application
    Categories=AudioVideo;Player;
    EOF
  '';

  meta = with lib; {
    description = "多数据源桌面音乐播放器";
    homepage = "https://github.com/stark81/VutronMusic";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "vutronmusic";
    maintainers = [ ];
  };
}
