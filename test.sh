docker build -q -t rar .
docker run --rm --name rar -d -p 8080:8080 rar

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":0,"state":{"a":106,"b":0,"c":0,"d":0,"e":0,"h":0,"l":0,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":0,"stackPointer":0,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":0,"state":{"a":181,"b":0,"c":0,"d":0,"e":0,"h":0,"l":0,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":4,"interruptsEnabled":true}}'

docker kill rar

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mRAR Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mRAR Test Fail  \e[0m"
    echo "$RESULT"
    echo "$EXPECTED"
    exit 1
fi