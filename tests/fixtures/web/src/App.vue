<script setup lang="ts">
import { greet } from "./a";

const message = greet("Vue");
</script>

<template>
  <p>{{ message }}</p>
</template>
