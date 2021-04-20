docker build -q -t rar .
docker run --rm --name rar -d -p 8080:8080 rar

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"opcode":0,"state":{"a":106,"b":0,"c":0,"d":0,"e":0,"h":0,"l":0,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":0,"stackPointer":0,"cycles":0}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"opcode":0,"state":{"a":181,"b":0,"c":0,"d":0,"e":0,"h":0,"l":0,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":0,"stackPointer":0,"cycles":4}}'

docker kill rar

if [ "$RESULT" = "$EXPECTED" ]; then
    echo -e "\e[32mrar Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mTLC Test Fail  \e[0m"
    echo "$RESULT"
    exit -1
fi