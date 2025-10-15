# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    philo_tester.sh                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ansebast <ansebast@student.42luanda.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/12/01 13:23:47 by ansebast          #+#    #+#              #
#    Updated: 2024/12/06 13:40:07 by ansebast         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/sh
BLACK="\e[30m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
W="\e[37m"
RESET="\e[0m"
BOLT="\e[1m"

echo "           __    _ __          __            __           "
echo "    ____  / /_  (_) /___      / /____  _____/ /____  _____"
echo "   / __ \/ __ \/ / / __ \    / __/ _ \/ ___/ __/ _ \/ ___/"
echo "  / /_/ / / / / / / /_/ /   / /_/  __(__  ) /_/  __/ /    "
echo " / .___/_/ /_/_/_/\____/____\__/\___/____/\__/\___/_/     "
echo "/_/                   /_____/                              "
echo ""

usage() {
	echo -e "$BOLT$C=========================================$RESET"
	echo -e "$BOLT$Y Lista de opcões do programa:$RESET"
	echo -e "$BOLT$C=========================================$RESET\n"

	echo -e "$BOLT$G  -d:$RESET$W Verifica$R data races$RESET e$R deadlocks$RESET"
	echo -e "$BOLT$G  -l:$RESET$W Verifica$R vazamentos de memória$RESET"
	echo -e "$BOLT$G  -s:$RESET$W Verifica cenários onde$R um filósofo deve morrer$RESET"
	echo -e "$BOLT$G  -c tempo:$RESET$W Verifica cenários onde$G nenhum filósofo deve morrer$RESET"
	echo -e "$BOLT$G  -t:$RESET$W Verifica$B o tempo de emissão da mensagem de morte$RESET"
	echo -e "$BOLT$G  -e:$RESET$W Verifica se$M todos os filósofos comem o número mínimo de vezes$RESET"
	echo -e "$BOLT$G  -a tempo:$RESET$W Executa todos os tipos de testes$RESET\n"

	echo -e "$BOLT$C=========================================$RESET"
	echo -e "$BOLT Exemplo: ./philo_tester.sh -c 60"
	echo -e "$BOLT$C=========================================$RESET"

	exit 127
}

redirect_output() {
	local log_file="$1"
	exec 3>&1
	exec 4>&2
	exec 1>>"$log_file"
	exec 2>>"$log_file"
}

restore_output() {
	exec 1>&3 3>&-
	exec 2>&4 4>&-
}

progress_bar() {
	total=$1
	current=$2
	width=50
	progress=$(((current * width) / total))
	remaining=$((width - progress))

	printf "\r["
	for i in $(seq 0 $(($progress - 1))); do
		printf "$G#$RESET"
	done
	for i in $(seq 0 $(($remaining - 1))); do
		printf "$R-$RESET"
	done
	printf "] %d%%" $(((current * 100) / total))
}

run_progress_bar() {
	total=100
	for i in $(seq 1 $total); do
		progress_bar $total $i
	done
	rm -f leaks.log output.log valgrind.log drd.log temp_output.log eating_test_*.log
}

cleanup() {
	restore_output
	echo -e "\n\n$R A encerrar execução do$BOLT$W Philosophers Tester$RESET$R. e Limpar recursos...$RESET"
	rm -f eating_test_*.log
	run_progress_bar
	echo -e "\n"
	exit 124
}

if [ "$#" -eq 0 ] || { [ "$1" != "-a" ] && [ "$1" != "-l" ] && [ "$1" != "-d" ] && [ "$1" != "-s" ] && [ "$1" != "-c" ] && [ "$1" != "-t" ] && [ "$1" != "-e" ]; }; then
	usage
elif { [ "$1" == "-a" ] || [ "$1" == "-c" ]; } && { [ "$#" != 2 ] || [ $(echo "$2" | grep -qE '^-?[0-9]+$') ]; }; then
	echo -e "$BOLT$C=========================================$RESET"
	echo -e "$BOLT Exemplo: ./philo_tester.sh $1 60"
	echo -e "$BOLT$C=========================================$RESET"
	exit 127
fi

if [ ! -f "./philo" ]; then
	echo -e "🚨 $RED Executável $BOLT'philo'$RESTE$RED não encontrado!"
	exit 1
fi

trap cleanup SIGINT

test_passed=0
test_failure=0
##===================Teste de cenários para Data Races
if [ "$1" = "-a" ] || [ "$1" = "-d" ]; then
	test_cases=(
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"$(shuf -i 1-79 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-3 -n 1)"
		"5 60 200 200 17"
		"77 800 600 200 10"
		"91 777 523 257 3"
		"3 600 300 300 100"
		"47 800 400 400 7"
		"2 100 100 100 147"
		"1 800 100 100 1000"
		"2 310 2000 100 579"
		"3 400 2000 150"
		"4 300 3000 150 1000"
		"5 500 2000 300 1000"
		"10 200 200 200 31"
		"100 120 65 65 7"
		"179 800 400 400 7"
		"5 1000 1000 1000 52"
		"4 310 200 200 100 5"
		"5 410 200 200 57"
		"3 600 300 300 123"
		"7 401 200 200 113"
	)
	echo -e "$BOLT$C==========================================================$RESET"
	echo -e "🔍 A Testar cenários para Deadlocks..."
	echo -e "$BOLT$C==========================================================$RESET\n"
	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		redirect_output "output.log"
		timeout 8 stdbuf -oL ./philo $case
		restore_output
		if [ $? -eq 124 ]; then
			echo -e "❌ Deadlock detectado (programa travou ou demorou demais).\n"
			test_failure=$(( $test_failure + 1 ))
		else
			echo -e "✅ Sem deadlock detectado.\n"
			test_passed=$(( $test_passed + 1 ))
		fi
	done
	echo -e "\n"

	echo -e "$BOLT$C==========================================================$RESET"
	echo -e "🔍 A Testar cenários para Data Races com Helgrind..."
	echo -e "$BOLT$C==========================================================$RESET\n"

	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		redirect_output "valgrind.log"
		valgrind --tool=helgrind ./philo $case
		restore_output
		if grep -q "data race" valgrind.log; then
			echo -e "❌ Possível Data Race detectado!\n"
			test_failure=$(( $test_failure + 1 ))
		else
			echo -e "✅ Sem Data Races detectados.\n"
			test_passed=$(( $test_passed + 1 ))
		fi
	done
	echo -e "\n"

	echo -e "$BOLT$C=====================================================$RESET"
	echo -e "🔍 A Testar cenários para Data Races com DRD..."
	echo -e "$BOLT$C=====================================================$RESET\n"
	for case in "${test_cases[@]}"; do
		echo "🧪 caso: ./philo $case"

		redirect_output "drd.log"
		valgrind --tool=drd --check-stack-var=yes ./philo $case
		restore_output
		if grep -q "Conflicting" drd.log; then
			echo "❌ Data Race detectado!"
			test_failure=$(( $test_failure + 1 ))
		else
			echo "✅ Sem Data Races detectados."
			test_passed=$(( $test_passed + 1 ))
		fi
		echo -e "\n"
	done
	rm -f output.log valgrind.log drd.log
	echo -e "\n"
fi

#===================Testes de vazamento de memória
if [ "$1" = "-a" ] || [ "$1" = "-l" ]; then
	echo -e "$BOLT$C=====================================================$RESET"
	echo "🔍 A Iniciar testes de vazamento de memória..."
	echo -e "$BOLT$C=====================================================$RESET\n"
	test_cases=(
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 800-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"$(shuf -i 1-179 -n 1) $(shuf -i 400-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 60-800 -n 1) $(shuf -i 1-5 -n 1)"
		"0 0 0 0"
		"0 0 0 0 0"
		"0 200 200 200"
		""
		"5 0 200 200"
		"5 800 0 200"
		"5 800 200 0"
		"-5 800 200 200"
		" 5 -800 200 200"
		"5 800 200 200 7"
		"10 200 200 200"
		"3 600 300 300"
		"100 50 25 25"
		"179 800 200 200"
		"asd asd ad asd"
		"1 sad asd asd"
		"5 1000 200 200 abc"
		"1 800 200 200 999999999999999999999999999999999999"
		"2 999999999999999999999999999999999999 999999999999999999999999999999999999 999999999999999999999999999999999999 999999999999999999999999999999999999"
		"2 800 200 200 3"
		"1 800 200 200"
		"200 800 2000 200"
		"5 4000 2000 2000"
		"5 200 100 100"
		"7 800 200 200 10"
		"5 800 200 200 9223372036854775809"
		"1 -92233720368547758099 200 200 10"
		"5 1 1 1 10"
		"-1 800 200 200"
		"0 800 200 200"
		"200 800 200 200 1"
	)

	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		timeout 60 valgrind --leak-check=full ./philo $case >leaks.log 2>&1
		leaks_count=$(grep -c "lost" leaks.log)
		if [ $leaks_count -ne 0 ]; then
			echo "❌ Vazamento de memória detectado!"
			test_failure=$(( $test_failure + 1 ))
		else
			echo -e "✅ Sem vazamentos de memória!\n"
			test_passed=$(( $test_passed + 1 ))
		fi
	done
	rm -f leaks.log
	echo -e "\n"
fi

#===================Testes de cenários onde nenhum filósofo deve morrer
if [ "$1" = "-a" ] || [ "$1" = "-c" ]; then
	echo -e "$BOLT$C=====================================================$RESET"
	echo "🔍 A Testar cenários onde nenhum filósofo deve morrer..."
	echo -e "$BOLT$C=====================================================$RESET\n"

	test_cases=(
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"2 410 200 200"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-300 -n 1)"
		"$(shuf -i 2-50 -n 1) $(shuf -i 1000-2000 -n 1) $(shuf -i 100-300 -n 1) $(shuf -i 100-200 -n 1)"
		"5 800 200 200"
		"137 1000 200 200"
		"78 1000 200 200"
		"4 410 200 200"
		"4 700 300 300"
		"3 1800 400 400"
		"2 1010 500 500"
		"11 367 77 91"
		"27 733 112 235"
		"4 1000 313 412"
		"3 1000 100 100"
	)

	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		echo >output.log
		redirect_output "output.log"
		timeout "$2" stdbuf -oL ./philo $case
		restore_output

		death_message=$(grep "died" output.log)

		echo "Resultado:"
		if [ -n "$death_message" ]; then
			echo "❌ Um Filósofo morreu 😭"
			test_failure=$(( $test_failure + 1 ))
			echo -e "📜 Log de morte: $death_message ☠️\n"
		else
			echo -e "✅ Nenhum Filósofo morreu 😇\n"
			test_passed=$(( $test_passed + 1 ))
		fi
	done
	echo -e "\n"
fi

##===================Validação do tempo de morte
if [ "$1" = "-a" ] || [ "$1" = "-t" ]; then
	echo -e "$BOLT$C=====================================================$RESET"
	echo -e "⏱️ A Verificar tempo de emissão das mensagens de morte"
	echo -e "$BOLT$C=====================================================$RESET\n"

	test_cases=(
		"$(shuf -i 3-79 -n 1) 800 6000 200 1000"
		"$(shuf -i 3-79 -n 1) 777 523 257"
		"$(shuf -i 3-79 -n 1) 600 2000 1000 1000"
		"$(shuf -i 3-79 -n 1) 800 4000 100 1000"
		"2 100 1000 1000 1000"
		"1 800 100 100 1000"
		"2 310 2000 1000 1000"
		"$(shuf -i 3-79 -n 1) 60 200 200 1000"
		"$(shuf -i 3-79 -n 1) 800 600 200 1000"
		"$(shuf -i 3-79 -n 1) 777 523 257"
		"3 600 300 300 1000"
		"$(shuf -i 3-79 -n 1) 800 400 400 1000"
		"2 100 100 100 1000"
		"1 800 100 100 1000"
		"4 310 200 200"
		"2 310 2000 100 1000"
		"3 400 2000 150"
		"4 300 3000 150 1000"
		"5 500 2000 300 1000"
		"$(shuf -i 3-79 -n 1) 200 200 5"
		"100 120 65 65"
		"179 800 400 400"
		"$(shuf -i 3-179 -n 1) 1000 1000 1000 3"
		"4 310 200 200"
		"5 410 200 200"
		"3 600 300 300"
		"7 401 200 200"
		"4 310 200 100"
	)

	for case in "${test_cases[@]}"; do
		echo "🧪 A Testar caso: ./philo $case"
		timeout 10 stdbuf -oL ./philo $case >temp_output.log 2>&1

		death_message=$(grep "died" temp_output.log)
		if [ -z "$death_message" ]; then
			echo "❌ Tempo esgotado. Nenhum filósofo morreu neste cenário."
			test_failure=$(( $test_failure + 1 ))
		else
			echo "📜 Log de morte: $death_message"
			death_time=$(echo "$death_message" | awk '{print $1}')
			philosopher_id=$(echo "$death_message" | awk '{print $2}')
			last_eat_time=$(awk '/$philosopher_id .* is eating/ {line=$0} END {print line}' temp_output.log)

			if [ -z "$last_eat_time" ]; then
				last_eat_time=0
			fi
			time_since_last_eat=$((death_time - last_eat_time))
			excess_time=$((time_since_last_eat - $(echo $case | awk '{print $2}')))

			if [ "$excess_time" -gt 10 ]; then
				echo "❌ Tempo de emissão da mensagem excedeu 10ms: Excesso de $excess_time ms."
				test_failure=$(( $test_failure + 1 ))
			else
				echo "✅ Mensagem emitida dentro do limite de tempo permitido."
				test_passed=$(( $test_passed + 1 ))
			fi
		fi
		echo -e "\n"
	done
	rm -f temp_output.log
	echo -e "\n"
fi

##===================Testes de cenários onde um filósofo deve morrer
if [ "$1" = "-a" ] || [ "$1" = "-s" ]; then
	echo -e "$BOLT$C=====================================================$RESET"
	echo "🔍 A Testar cenários onde um filósofo deve morrer..."
	echo -e "$BOLT$C=====================================================$RESET\n"
	test_cases=(
		"$(shuf -i 3-79 -n 1) 800 6000 200 1000"
		"$(shuf -i 3-79 -n 1) 777 523 257"
		"$(shuf -i 3-79 -n 1) 600 2000 1000 1000"
		"$(shuf -i 3-79 -n 1) 800 4000 100 1000"
		"2 100 1000 1000 1000"
		"1 800 100 100 1000"
		"2 310 2000 1000 1000"
		"$(shuf -i 3-79 -n 1) 60 200 200 1000"
		"$(shuf -i 3-79 -n 1) 800 600 200 1000"
		"$(shuf -i 3-79 -n 1) 777 523 257"
		"3 600 300 300 1000"
		"$(shuf -i 3-79 -n 1) 800 400 400 1000"
		"2 100 100 100 1000"
		"1 800 100 100 1000"
		"2 310 2000 100 1000"
		"3 400 2000 150"
		"4 300 3000 150 1000"
		"5 500 2000 300 1000"
		"$(shuf -i 3-79 -n 1) 200 200 200"
		"100 120 65 65"
		"179 800 400 400"
		"$(shuf -i 3-179 -n 1) 1000 1000 1000 100"
		"4 310 200 200"
		"5 410 200 200"
		"3 600 300 300"
		"7 401 200 200"
	)

	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		echo >output.log
		redirect_output "output.log"
		timeout 10 stdbuf -oL ./philo $case
		restore_output

		death_message_count=$(grep -c "died" output.log)
		post_death_messages=$(grep -A1 "died" output.log | tail -n +2)

		echo "Resultado:"
		if [ "$death_message_count" -eq 1 ]; then
			echo -e "✅ Apenas uma mensagem de morte encontrada.\n"
			test_passed=$(( $test_passed + 1 ))
		else
			echo -e "❌ Tempo esgotado. Número incorreto de mensagens de morte ($death_message_count encontradas).\n"
			test_failure=$(( $test_failure + 1 ))
		fi

		if [ ! -z "$post_death_messages" ]; then
			echo -e "❌ Mensagens encontradas após a morte:\n"
			test_failure=$(( $test_failure + 1 ))
			echo -e "$post_death_messages\n"
		fi
	done
	rm -f output.log
	echo -e "\n"
fi

##===================Testes de validação do número de vezes que cada filósofo come
if [ "$1" = "-a" ] || [ "$1" = "-e" ]; then
	echo -e "$BOLT$C=====================================================$RESET"
	echo -e "🍽️ A Verificar se todos os filósofos comem o número mínimo de vezes..."
	echo -e "$BOLT$C=====================================================$RESET\n"

	test_cases=(
		"3 1000 200 200 5"
		"4 800 150 150 7"
		"2 1200 300 300 10"
		"2 800 200 200 3"
		"6 1000 250 250 4"
		"7 1500 200 200 6"
		"3 2000 400 400 15"
		"4 1000 200 200 8"
		"5 800 150 150 5"
		"2 1500 300 300 10"
		"8 1200 200 200 3"
		"4 1000 250 250 12"
		"4 2000 500 500 20"
		"5 900 180 180 6"
		"6 1100 220 220 4"
	)

	for case in "${test_cases[@]}"; do
		echo "🧪 Caso de teste: ./philo $case"
		
		# Extrair parâmetros do caso de teste
		num_philos=$(echo $case | awk '{print $1}')
		must_eat=$(echo $case | awk '{print $5}')
		
		if [ -z "$must_eat" ]; then
			echo "⚠️ Caso sem número de refeições especificado, a saltar..."
			continue
		fi
		
		# Criar nome único para o arquivo de log
		timestamp=$(date +%s%N)
		log_file="eating_test_${timestamp}.log"
		
		echo >$log_file
		redirect_output "$log_file"
		timeout 30 stdbuf -oL ./philo $case
		restore_output
		
		echo "📊 A analisar refeições de cada filósofo..."
		
		all_philosophers_ok=true
		
		# Verificar cada filósofo individualmente
		for philo_id in $(seq 1 $num_philos); do
			eating_count=$(grep -c "$philo_id is eating" $log_file)
			echo "   Filósofo $philo_id: $eating_count refeições (mínimo: $must_eat)"
			
			if [ $eating_count -lt $must_eat ]; then
				echo "   ❌ Filósofo $philo_id não comeu o suficiente!"
				all_philosophers_ok=false
			fi
		done
		
		if [ "$all_philosophers_ok" = true ]; then
			echo -e "✅ Todos os filósofos comeram pelo menos $must_eat vezes!\n"
			test_passed=$(( $test_passed + 1 ))
		else
			echo -e "❌ Nem todos os filósofos comeram o número mínimo de vezes!\n"
			test_failure=$(( $test_failure + 1 ))
		fi
		
		# Limpar arquivo de log específico
		rm -f $log_file
	done
	echo -e "\n"
fi

echo -e "$BOLT$C=========================================$RESET"
echo -e "🔨 Testes Efectuados: $(( $test_passed + $test_failure ))"
echo -e "✅ OK: $test_passed"
echo -e "❌ KO: $test_failure"
echo -e "$BOLT$C=========================================$RESET\n"

echo -e "O projecto foi útil? Deixe sua estrela no$BOLT GitHub!$RESET ⭐🥺"
echo -e "Aqui está do link repositório:$B$BOLT https://github.com/AntonioSebastiaoPedro/philosophers_tester$RESET"
