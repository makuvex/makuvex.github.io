---
title: "lo"
categories:
  - etc
tags:
  - etc
---

### content

 <!DOCTYPE html>
<html>
<body>
    <input type="button" id="hw" value="Hello world" />
    <script type="text/javascript">
      const arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
const result = [];

while (result.length < 6) {
  const randomIndex = Math.floor(Math.random() * arr.length);
  const randomNumber = arr[randomIndex];
  if (!result.includes(randomNumber)) {
    result.push(randomNumber);
  }
}

console.log(result);

    </script>
</body>
</html>