export CONFLUENT_HOME=/Users/bmartin/swtools/confluent-7.4.0
export PATH="${CONFLUENT_HOME}/bin:$PATH"
alias kstat='docker compose -f ~/swtools/kafka-stack-docker-compose/single-7.4.0.yml ps'
# alias kstart='confluent local services kafka start'
alias kstart='cd ~/swtools/kafka-stack-docker-compose/ && docker compose -f single-7.4.0.yml up --detach; cd -'
# alias kstop='confluent local services kafka stop'
alias kstop='cd ~/swtools/kafka-stack-docker-compose/ && docker compose -f single-7.4.0.yml down; cd -'
alias ktopic='kafka-topics --zookeeper localhost:2181'
