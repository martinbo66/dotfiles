if [ -d /System/Library/Frameworks/JavaVM.framework/Versions/1.6 ]; then
  export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home
  export MAVEN_OPTS="-Xmx512m -XX:+HeapDumpOnOutOfMemoryError"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="~/.sdkman"
[ -f ~/.sdkman/bin/sdkman-init.sh ] && source ~/.sdkman/bin/sdkman-init.sh
