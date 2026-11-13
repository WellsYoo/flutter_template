import 'package:flutter/material.dart';
import 'package:xjj_app_base/features/demo/ui_kit/demo_block.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

/// 录入：搜索框、表单行、步进器、验证码、输入限制与校验
class InputTab extends StatefulWidget {
  const InputTab({super.key});

  @override
  State<InputTab> createState() => _InputTabState();
}

class _InputTabState extends State<InputTab> {
  int _count = 1;
  bool _invoice = true;
  String _payment = '银行转账';
  DateTime? _date;
  String _keyword = '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    final c = context.xColors;
    return DemoTab(
      children: [
        DemoBlock(
          title: 'XSearchField 搜索框',
          code: 'XSearchField(round: true, onChanged: (v) => ...) // 自带防抖和清除',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              XSearchField(
                round: true,
                hintText: '输入后停顿 0.4 秒才回调',
                onChanged: (v) => setState(() => _keyword = v),
              ),
              XText.caption(_keyword.isEmpty ? '还没有输入' : '搜索：$_keyword'),
            ],
          ),
        ),
        DemoBlock(
          title: 'XFormItem 表单行',
          code:
              "XFormItem.input(label: '金额', suffix: '元', inputFormatters: [InputFormats.decimal(2)])\nXFormItem.date(label: '日期', value: date, onChanged: ...)",
          child: XContainer(
            radius: 12,
            clip: true,
            border: true,
            child: XFormSection(
              margin: EdgeInsets.zero,
              children: [
                XFormItem.input(
                  label: '合同金额',
                  required: true,
                  suffix: '元',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [InputFormats.decimal(2)],
                ),
                XFormItem.date(
                  label: '签订日期',
                  value: _date,
                  onChanged: (v) => setState(() => _date = v),
                ),
                XFormItem.radio(
                  label: '付款方式',
                  options: const ['银行转账', '承兑汇票'],
                  value: _payment,
                  onChanged: (v) => setState(() => _payment = v),
                ),
                XFormItem.switcher(
                  label: '需要发票',
                  value: _invoice,
                  onChanged: (v) => setState(() => _invoice = v),
                ),
              ],
            ),
          ),
        ),
        DemoBlock(
          title: 'XStepper / XCountdownButton',
          code:
              'XStepper(value: n, min: 1, max: stock, onChanged: ...)\nXCountdownButton(onSend: () => repo.sendCode(phone))',
          child: Row(
            children: [
              XStepper(value: _count, max: 5, onChanged: (v) => setState(() => _count = v)),
              XGap.h8,
              const XText.caption('最多 5'),
              const Spacer(),
              XCountdownButton(
                seconds: 10,
                onSend: () => Future<void>.delayed(const Duration(milliseconds: 500)),
              ),
            ],
          ),
        ),
        DemoBlock(
          title: 'InputFormats / Validators',
          code: 'inputFormatters: InputFormats.phone\nValidators.phone(value) // 返回 null 表示通过',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              TextField(
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormats.phone,
                decoration: const InputDecoration(hintText: '只能输入 11 位数字', isDense: true),
                onChanged: (v) => setState(() => _phone = v),
              ),
              if (_phone.isNotEmpty)
                Validators.phone(_phone) == null
                    ? XText.caption('格式正确，脱敏后：${_phone.mask()}', color: c.success)
                    : XText.caption(Validators.phone(_phone)!, color: c.danger),
            ],
          ),
        ),
      ],
    );
  }
}
