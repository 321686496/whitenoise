<template>
  <view class="icon-wrap" :style="wrapStyle">
    <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" :stroke="color" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <!-- 声音/波形 -->
      <template v-if="name === 'wave'">
        <path d="M2 12h2l3-9 4 18 4-14 3 7h4" />
      </template>
      <!-- 白噪音 -->
      <template v-else-if="name === 'white-noise'">
        <path d="M2 12c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
        <path d="M2 16c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
        <path d="M2 8c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
      </template>
      <!-- 粉红噪音 -->
      <template v-else-if="name === 'pink-noise'">
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v4M12 18v4M2 12h4M18 12h4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
      </template>
      <!-- 褐噪音 -->
      <template v-else-if="name === 'brown-noise'">
        <path d="M3 17c3-2 6-2 9 0s6 2 9 0" />
        <path d="M3 13c3-2 6-2 9 0s6 2 9 0" />
        <path d="M3 9c3-2 6-2 9 0s6 2 9 0" />
        <path d="M3 5c3-2 6-2 9 0s6 2 9 0" />
      </template>
      <!-- 棕噪音 -->
      <template v-else-if="name === 'red-noise'">
        <path d="M4 20c2-4 4-4 6 0s4 4 6 0 4-4 6 0" stroke-width="2.5" />
      </template>
      <!-- 雨 -->
      <template v-else-if="name === 'rain'">
        <path d="M16 13V8a4 4 0 0 0-8 0v1" />
        <path d="M12 13v5M8 15v4M16 15v4M4 13v3M20 13v3" />
      </template>
      <!-- 海浪 -->
      <template v-else-if="name === 'wave-ocean'">
        <path d="M2 12c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
        <path d="M2 16c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
        <path d="M2 8c2-3 4-3 6 0s4 3 6 0 4-3 6 0" />
      </template>
      <!-- 森林 -->
      <template v-else-if="name === 'forest'">
        <path d="M12 3L7 10h3l-4 7h12l-4-7h3L12 3z" />
        <path d="M12 17v4" />
      </template>
      <!-- 溪流 -->
      <template v-else-if="name === 'stream'">
        <path d="M12 2c-3 4-6 6-6 10a6 6 0 0 0 12 0c0-4-3-6-6-10z" />
        <path d="M12 10v4M10 12h4" />
      </template>
      <!-- 篝火 -->
      <template v-else-if="name === 'fire'">
        <path d="M12 2c-1 3-4 5-4 9a4 4 0 0 0 8 0c0-2-1-3-2-4 1 1 2 2 2 4" />
        <path d="M8 21h8M10 17h4" />
      </template>
      <!-- 咖啡厅 -->
      <template v-else-if="name === 'coffee'">
        <path d="M17 8h1a4 4 0 0 1 0 8h-1" />
        <path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V8z" />
        <path d="M6 2v2M10 2v2M14 2v2" />
      </template>
      <!-- 列车 -->
      <template v-else-if="name === 'train'">
        <rect x="4" y="3" width="16" height="14" rx="3" />
        <path d="M4 11h16M8 21l-2-4M16 21l2-4" />
        <circle cx="8" cy="15" r="1" fill="currentColor" stroke="none" />
        <circle cx="16" cy="15" r="1" fill="currentColor" stroke="none" />
      </template>
      <!-- 风扇 -->
      <template v-else-if="name === 'fan'">
        <circle cx="12" cy="12" r="2" />
        <path d="M12 10c-2-4-2-7 0-8s2 4 0 8" />
        <path d="M14 12c4-2 7-2 8 0s-4 2-8 0" />
        <path d="M12 14c2 4 2 7 0 8s-2-4 0-8" />
        <path d="M10 12c-4 2-7 2-8 0s4-2 8 0" />
      </template>
      <!-- 播放 -->
      <template v-else-if="name === 'play'">
        <polygon points="6,3 20,12 6,21" fill="currentColor" stroke="none" />
      </template>
      <!-- 暂停 -->
      <template v-else-if="name === 'pause'">
        <rect x="6" y="4" width="4" height="16" rx="1" fill="currentColor" stroke="none" />
        <rect x="14" y="4" width="4" height="16" rx="1" fill="currentColor" stroke="none" />
      </template>
      <!-- 定时器 -->
      <template v-else-if="name === 'timer'">
        <circle cx="12" cy="13" r="8" />
        <path d="M12 9v4l2 2" />
        <path d="M9 2h6" />
      </template>
      <!-- 保存 -->
      <template v-else-if="name === 'save'">
        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z" />
        <polyline points="17,21 17,13 7,13 7,21" />
        <polyline points="7,3 7,8 15,8" />
      </template>
      <!-- 主题/调色板 -->
      <template v-else-if="name === 'palette'">
        <circle cx="12" cy="12" r="10" />
        <circle cx="12" cy="8" r="1.5" fill="currentColor" stroke="none" />
        <circle cx="8.5" cy="12" r="1.5" fill="currentColor" stroke="none" />
        <circle cx="15.5" cy="12" r="1.5" fill="currentColor" stroke="none" />
        <circle cx="10" cy="15.5" r="1.5" fill="currentColor" stroke="none" />
      </template>
      <!-- 成就/奖杯 -->
      <template v-else-if="name === 'trophy'">
        <path d="M6 9H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h2" />
        <path d="M18 9h2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2" />
        <path d="M6 3h12v6a6 6 0 0 1-12 0V3z" />
        <path d="M9 21h6M12 15v6" />
      </template>
      <!-- 设置/齿轮 -->
      <template v-else-if="name === 'settings'">
        <circle cx="12" cy="12" r="3" />
        <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" />
      </template>
      <!-- 分享 -->
      <template v-else-if="name === 'share'">
        <circle cx="18" cy="5" r="3" />
        <circle cx="6" cy="12" r="3" />
        <circle cx="18" cy="19" r="3" />
        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49" />
        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />
      </template>
      <!-- 用户 -->
      <template v-else-if="name === 'user'">
        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
        <circle cx="12" cy="7" r="4" />
      </template>
      <!-- 编辑 -->
      <template v-else-if="name === 'edit'">
        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
      </template>
      <!-- 静音 -->
      <template v-else-if="name === 'mute'">
        <polygon points="11,5 6,9 2,9 2,15 6,15 11,19" />
        <line x1="23" y1="9" x2="17" y2="15" />
        <line x1="17" y1="9" x2="23" y2="15" />
      </template>
      <!-- 音量 -->
      <template v-else-if="name === 'volume'">
        <polygon points="11,5 6,9 2,9 2,15 6,15 11,19" />
        <path d="M15.54 8.46a5 5 0 0 1 0 7.07" />
        <path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
      </template>
      <!-- 关闭/删除 -->
      <template v-else-if="name === 'close'">
        <line x1="18" y1="6" x2="6" y2="18" />
        <line x1="6" y1="6" x2="18" y2="18" />
      </template>
      <!-- 箭头右 -->
      <template v-else-if="name === 'chevron-right'">
        <polyline points="9,18 15,12 9,6" />
      </template>
      <!-- 礼物 -->
      <template v-else-if="name === 'gift'">
        <polyline points="20,12 20,22 4,22 4,12" />
        <rect x="2" y="7" width="20" height="5" />
        <line x1="12" y1="22" x2="12" y2="7" />
        <path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z" />
        <path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z" />
      </template>
      <!-- 月亮 -->
      <template v-else-if="name === 'moon'">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
      </template>
      <!-- 火焰 -->
      <template v-else-if="name === 'flame'">
        <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" />
      </template>
      <!-- 调音台 -->
      <template v-else-if="name === 'mixer'">
        <line x1="4" y1="21" x2="4" y2="14" />
        <line x1="4" y1="10" x2="4" y2="3" />
        <line x1="12" y1="21" x2="12" y2="12" />
        <line x1="12" y1="8" x2="12" y2="3" />
        <line x1="20" y1="21" x2="20" y2="16" />
        <line x1="20" y1="12" x2="20" y2="3" />
        <line x1="1" y1="14" x2="7" y2="14" />
        <line x1="9" y1="8" x2="15" y2="8" />
        <line x1="17" y1="16" x2="23" y2="16" />
      </template>
      <!-- 时钟 -->
      <template v-else-if="name === 'clock'">
        <circle cx="12" cy="12" r="10" />
        <polyline points="12,6 12,12 16,14" />
      </template>
      <!-- 复制 -->
      <template v-else-if="name === 'copy'">
        <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
        <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
      </template>
      <!-- 锁 -->
      <template v-else-if="name === 'lock'">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </template>
      <!-- 检查 -->
      <template v-else-if="name === 'check'">
        <polyline points="20,6 9,17 4,12" />
      </template>
      <!-- 山 -->
      <template v-else-if="name === 'mountain'">
        <path d="M8 21l4-11 4 11" />
        <path d="M2 21l6-14 4 8" />
        <path d="M14 21l4-8 4 8" />
      </template>
      <!-- 鸟 -->
      <template v-else-if="name === 'bird'">
        <path d="M16 7c-2-2-5-2-7 0-3 3-3 7 0 10 2 2 5 3 8 2" />
        <path d="M16 7c1-3 4-4 6-3" />
        <circle cx="13" cy="9" r="1" fill="currentColor" stroke="none" />
      </template>
      <!-- 默认圆点 -->
      <template v-else>
        <circle cx="12" cy="12" r="8" />
      </template>
    </svg>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  name: string
  size?: number | string
  color?: string
}>(), {
  size: 24,
  color: 'currentColor',
})

const wrapStyle = computed(() => ({
  width: typeof props.size === 'number' ? `${props.size}px` : props.size,
  height: typeof props.size === 'number' ? `${props.size}px` : props.size,
  display: 'inline-flex',
  alignItems: 'center',
  justifyContent: 'center',
  color: props.color,
}))

// 通过 style 注入 stroke，支持 var(--x) 等 CSS 变量
const svgStyle = computed(() => ({ stroke: props.color }))
</script>
