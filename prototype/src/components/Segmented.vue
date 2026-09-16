<template>
  <view class="seg">
    <view
      v-for="opt in options" :key="opt.key"
      class="seg-item" :class="{ on: opt.key === modelValue }"
      @click="$emit('update:modelValue', opt.key)"
    >
      <text>{{ opt.label }}</text>
    </view>
  </view>
</template>

<script setup lang="ts">
defineProps<{ options: { key: string; label: string }[]; modelValue: string }>()
defineEmits<{ (e: 'update:modelValue', key: string): void }>()
</script>

<style lang="scss" scoped>
.seg {
  display: flex; gap: 8rpx; padding: 6rpx;
  background: var(--app-surface-2); border-radius: 999rpx; border: 1rpx solid var(--app-line);
}
.seg-item {
  flex: 1; min-height: 88rpx; display: flex; align-items: center; justify-content: center;
  border-radius: 999rpx; font-size: 26rpx; color: var(--app-text-2); font-weight: 500;
  transition: all var(--dur-base) var(--ease-std);
}
.seg-item.on {
  background: var(--app-surface); color: var(--app-text); font-weight: 600;
  box-shadow: var(--app-shadow-1);
}
/* neu 风格下选中 = 凹陷（方向反转），与铁律一致 */
:global(:root[data-ui='neu'] .seg-item.on) { box-shadow: inset 4rpx 4rpx 8rpx var(--p-neu-a), inset -4rpx -4rpx 8rpx var(--p-neu-b); background: var(--app-bg); }
</style>
