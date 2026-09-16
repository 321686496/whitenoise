<template>
  <view class="tabbar">
    <view class="tabbar-pill">
      <view
        v-for="t in TABS"
        :key="t.key"
        class="tabbar-item"
        :class="{ 'tabbar-item--on': t.key === current }"
        @tap="go(t.key)"
      >
        <svg
          class="tabbar-ic"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.6"
          stroke-linecap="round"
          stroke-linejoin="round"
          :style="{ color: t.key === current ? 'var(--app-primary)' : 'var(--app-text-3)' }"
          v-html="t.path"
        ></svg>
        <text class="tabbar-text">{{ t.text }}</text>
        <view class="tabbar-dot" :class="{ 'tabbar-dot--on': t.key === current }"></view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ current: string }>(), { current: 'index' })

/* 图标路径沿用 static/tab-*.svg 的绘制（描边使用 currentColor 跟随主题） */
const TABS = [
  { key: 'index', text: '首页', path: '<path d="M3 18c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 15c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 12c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/><path d="M3 9c2-2.5 4-2.5 6 0s4 2.5 6 0 4-2.5 6 0"/>' },
  { key: 'scene', text: '场景', path: '<path d="M4 20l4-10 3 6 3-8 3 6 3-6 3 12"/><circle cx="17" cy="6" r="1.2" fill="currentColor" stroke="none"/>' },
  { key: 'discover', text: '发现', path: '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>' },
  { key: 'mine', text: '我的', path: '<path d="M14 5c-1-1.5-2.5-2-4-1.5C8.5 4 7.5 5.5 8 7c.3 1 1 1.8 2 2.2"/><path d="M20 21v-1.5a3.5 3.5 0 0 0-3.5-3.5H7.5A3.5 3.5 0 0 0 4 19.5V21"/><circle cx="10" cy="8.5" r="2.5"/>' },
]

function go(key: string) {
  uni.switchTab({ url: `/pages/${key}/${key}` })
}
</script>

<style lang="scss" scoped>
.tabbar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 90;
  height: calc(var(--app-tab-height, 100rpx) + constant(safe-area-inset-bottom));
  height: calc(var(--app-tab-height, 100rpx) + env(safe-area-inset-bottom));
  display: flex;
  align-items: flex-end;
  justify-content: center;
  padding: 0 24rpx 12rpx;
  pointer-events: none; /* 底部留白不挡页面点击 */
}

.tabbar-pill {
  width: 100%;
  height: 112rpx;
  border-radius: 34rpx;
  display: flex;
  align-items: center;
  padding: 6rpx 10rpx;
  pointer-events: auto;
  background: var(--app-surface);
  border: 1rpx solid var(--app-line);
  box-shadow: var(--app-shadow-3), var(--app-inset);
  backdrop-filter: blur(var(--app-blur, 0px));
  -webkit-backdrop-filter: blur(var(--app-blur, 0px));
}

.tabbar-item {
  position: relative;
  flex: 1;
  height: 88rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2rpx;
  border-radius: 999rpx;
  transition: background var(--dur-fast) var(--ease-std), transform var(--dur-fast) var(--ease-std);

  &:active {
    transform: scale(0.96);
  }

  /* v2 选中态：整项底色药丸（不再上浮），靠主色 + 指示点区分 */
  &--on {
    background: var(--app-primary-soft);
  }
}

.tabbar-ic {
  display: block;
  width: 52rpx;
  height: 52rpx;
}

.tabbar-text {
  font-size: 19rpx;
  color: var(--app-text-3);
  font-weight: 500;
  letter-spacing: 0.5rpx;

  .tabbar-item--on & {
    color: var(--app-primary);
    font-weight: 700;
  }
}

/* 6rpx×24rpx 横条指示点：未选中占位透明，选中显主色 */
.tabbar-dot {
  width: 24rpx;
  height: 6rpx;
  border-radius: 999rpx;
  background: transparent;
  transition: background var(--dur-fast) var(--ease-std);

  &--on {
    background: var(--app-primary);
  }
}
</style>
